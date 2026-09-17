# Infraestrutura TechNova — Aula 05: RDS e Remote State

**Aluno:** Andreyh Rodrigues de Souza — **RA:** 6325231

## Arquitetura

```text
Internet → IGW → Route Table pública → Subnet pública AZ A → EC2 t2.micro
VPC 10.0.0.0/16                                               │ psql :5432
├── Pública A: 10.0.1.0/24                                   │
├── Privada A: 10.0.2.0/24 ─┐                                 ▼
└── Privada B: 10.0.4.0/24 ─┴── DB Subnet Group → RDS PostgreSQL 15
                                                   db.t3.micro (Single-AZ)
Terraform → S3 (state cifrado/versionado/privado) + DynamoDB (LockID)
```

As duas subnets privadas permitem posicionar o banco em duas AZs; `multi_az = false` mantém uma única instância RDS. Não existe NAT Gateway. O SG do banco permite 5432 somente do CIDR da VPC. O SG do EC2 permite SSH e porta 3000; o TF 5 exige cliente psql, não uma nova API.

## Pré-requisitos

AWS Academy iniciado, credenciais temporárias configuradas localmente, Terraform >= 1.5, AWS CLI, Python 3 e chave SSH. O default é `~/.ssh/technova-key.pub`; nesta execução foi usada a chave pública existente `~/.ssh/id_ed25519.pub`. Informe `public_key_path` conforme sua máquina. Não versione credenciais, senha, state ou chave privada.

## Backend compatível com o Academy

A política organizacional do Learner Lab nega `s3:GetBucketObjectLockConfiguration`. O recurso `aws_s3_bucket` consulta essa API mesmo sem habilitar Object Lock, e falha. Por isso a criação e remoção do bucket são feitas pelo AWS CLI. Terraform gerencia as configurações de versionamento, cifragem AES256, Block Public Access e a tabela DynamoDB. Todos os requisitos do backend permanecem configurados; nenhuma permissão do Academy é alterada.

```bash
STATE_BUCKET="technova-state-6325231-$(aws sts get-caller-identity --query Account --output text)-$(date +%s)"
aws s3api create-bucket --bucket "$STATE_BUCKET" --region us-east-1
aws s3api put-bucket-tagging --bucket "$STATE_BUCKET" \
  --tagging 'TagSet=[{Key=Name,Value=technova-state},{Key=Project,Value=TechNova},{Key=Aula,Value=05},{Key=Owner,Value=6325231},{Key=ManagedBy,Value=AWSCLI}]'
export TF_VAR_bucket_name="$STATE_BUCKET"
terraform -chdir=backend init
terraform -chdir=backend plan
terraform -chdir=backend apply
```

O backend possui state local separado: preserve esse arquivo até a limpeza. A variável `bucket_name` também pode ser gravada no `backend/terraform.tfvars.json`, ignorado pelo Git.

## Criar a infraestrutura principal

```bash
terraform init -backend-config="bucket=$STATE_BUCKET"
read -rsp 'Senha do banco: ' TF_VAR_db_password
printf '\n'
export TF_VAR_db_password
export TF_VAR_public_key_path="$HOME/.ssh/id_ed25519.pub"
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

`db_name` e `db_username` possuem defaults e são configuráveis por variáveis. `db_password` é obrigatória e sensível. Pode-se usar `terraform.tfvars.json` local com permissões 600; ele está ignorado pelo Git.

## Migração de state demonstrada

Nesta execução, a infraestrutura principal foi primeiro aplicada **sem o bloco `backend "s3"`** em `providers.tf`, gerando state local. Depois, com S3 e DynamoDB configurados, o bloco foi recolocado e foi executado:

```bash
terraform init -migrate-state -backend-config="bucket=$STATE_BUCKET"
# Confirmar a cópia do state quando solicitado.
```

`evidencia-migracao.txt` registra a inicialização e a migração. O código final já contém o backend S3; novas execuções podem usá-lo diretamente, sem repetir a fase local.

## Evidências

Execução real em 17/09/2026 no AWS Academy: 14 recursos principais provisionados; PostgreSQL 15.17 consultado pelo EC2; tabela `orders` criada e consultada em nova conexão; state migrado ao S3; plano final com `No changes`. Após a coleta, os 14 recursos principais e os 4 recursos de configuração do backend foram destruídos; todas as versões do state e o bucket foram removidos.

```bash
aws s3 ls "s3://$STATE_BUCKET/aula-05/" > evidencia-state-s3.txt
terraform plan -no-color > evidencia-plan.txt
terraform output -raw connection_string
ssh -i ~/.ssh/id_ed25519 ec2-user@IP_EC2
```

Na instância, aguarde `cloud-init status --wait`. Use o endpoint e o usuário do output. O psql pede a senha interativamente; não a coloque na linha de comando:

```bash
psql -h ENDPOINT -U technova_admin -d technova -W -c 'SELECT version();'
psql -h ENDPOINT -U technova_admin -d technova -W <<'SQL'
CREATE TABLE IF NOT EXISTS orders (id integer PRIMARY KEY, product text NOT NULL, quantity integer NOT NULL);
INSERT INTO orders VALUES (1, 'Pedido TechNova', 2) ON CONFLICT (id) DO NOTHING;
SQL
# Uma nova conexão consulta os dados persistidos:
psql -h ENDPOINT -U technova_admin -d technova -W -c 'SELECT * FROM orders;'
```

Saídas: `evidencia-conexao.txt` (`SELECT version()`), `evidencia-dados.txt` (consulta em nova conexão), `evidencia-state-s3.txt` (state no S3), `evidencia-plan.txt` (plano pós-apply sem mudanças). A senha não aparece nos registros.

## Destruir após as evidências

```bash
terraform destroy -no-color | tee evidencia-destroy.txt
```

Somente após confirmar a infraestrutura principal destruída, remova todas as versões e delete markers do bucket deste exercício. Use exatamente o nome exportado por `terraform -chdir=backend output -raw bucket_name`:

```bash
export STATE_BUCKET=$(terraform -chdir=backend output -raw bucket_name)
python3 - <<'PY'
import json, os, subprocess
bucket = os.environ['STATE_BUCKET']
versions = json.loads(subprocess.check_output([
    'aws', 's3api', 'list-object-versions', '--bucket', bucket, '--output', 'json']))
objects = [{'Key': v['Key'], 'VersionId': v['VersionId']}
           for kind in ('Versions', 'DeleteMarkers') for v in versions.get(kind, [])]
for start in range(0, len(objects), 1000):
    result = json.loads(subprocess.check_output([
        'aws', 's3api', 'delete-objects', '--bucket', bucket, '--delete',
        json.dumps({'Objects': objects[start:start+1000]}), '--output', 'json']))
    if result.get('Errors'):
        raise SystemExit(result['Errors'])
print('Versões e marcadores removidos:', len(objects))
PY
terraform -chdir=backend destroy -no-color | tee evidencia-destroy-backend.txt
aws s3api delete-bucket --bucket "$STATE_BUCKET" --region us-east-1
unset TF_VAR_db_password
```

O destroy do backend remove suas configurações e o DynamoDB; o bucket criado via CLI é removido pelo último comando. Confira os resultados antes de encerrar o Learner Lab.

## Organização e tags

`network.tf`: VPC/subnets/rotas; `security.tf`: SGs; `compute.tf`: EC2/key pair; `database.tf`: RDS/subnet group; `providers.tf`: backend e provider; `variables.tf` e `outputs.tf`: entradas e saídas. `backend/` contém as configurações S3 e o DynamoDB.

Todos os recursos que aceitam tags recebem `Name`, `Project` e `Aula`. Associações de rotas e configurações de bucket não possuem tags próprias. A senha é `sensitive`, mas o state ainda a contém: por isso o S3 é privado e cifrado, e arquivos de state não entram no Git.
