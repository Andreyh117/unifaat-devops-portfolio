# Infraestrutura TechNova — Aula 04

**Aluno:** Andreyh Rodrigues de Souza — **RA:** 6325231

## Arquitetura

```text
Internet → IGW → Route Table pública
                  │
VPC 10.0.0.0/16    │
├── AZ A          ├── Pública A 10.0.1.0/24 → EC2 t2.micro → API :3000
│                 │                          └── LabInstanceProfile → LabRole
│   Privada A 10.0.2.0/24 → tabela padrão (somente rota local)
└── AZ B          └── Pública B 10.0.3.0/24
    Privada B 10.0.4.0/24 → tabela padrão (somente rota local)
SG API: TCP 22/3000 da internet; SG futuro DB: TCP 5432 da VPC.
```

## Como usar

Pré-requisitos: AWS Academy Learner Lab iniciado, credenciais temporárias locais válidas, AWS CLI, Terraform >= 1.5, curl e OpenSSH. Região: us-east-1.

Crie uma chave exclusiva (não sobrescreva uma existente):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/technova-key
chmod 600 ~/.ssh/technova-key
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan -no-color > terraform-plan-output.txt
cp terraform-plan-output.txt evidencia-plan.txt
terraform apply
```

Se já possui outra chave, informe apenas o caminho público com `-var='public_key_path=~/.ssh/id_ed25519.pub'` em plan/apply/destroy. A chave privada nunca entra no Terraform nem no Git.

Aguarde o user data terminar e capture os resultados reais:

```bash
API_URL=$(terraform output -raw api_url)
EC2_IP=$(terraform output -raw ec2_public_ip)
curl --fail "$API_URL" > evidencia-api.json
curl --fail "$API_URL/health" >> evidencia-api.json
ssh -i ~/.ssh/technova-key ec2-user@"$EC2_IP" \
  'node --version && aws sts get-caller-identity' > evidencia-ssh.txt
terraform destroy -no-color | tee evidencia-destroy.txt
```

Se a API ainda não responder, consulte `sudo cat /var/log/technova-setup.log` e `sudo systemctl status technova-api` via SSH.

## Decisões técnicas e compatibilidade

- Duas AZs distribuem as quatro subnets e preparam a rede para expansão. A API possui **uma** instância, como pede o TF: a aplicação ainda não tem alta disponibilidade.
- Subnets privadas usam a tabela padrão, sem rota de internet. Não há NAT Gateway.
- Portas 22 e 3000 abertas à internet e 5432 restrita ao CIDR da VPC seguem exatamente os requisitos explícitos do TF 4.
- A AMI Amazon Linux 2023 x86_64 é localizada via data source. O user data instala Git e Node.js 18.20.8 a partir do arquivo oficial, verifica SHA-256, executa `npm install` e inicia a API simplificada permitida pelo enunciado. O systemd mantém o processo ativo.
- **Divergência do material:** o TF pede criar IAM Role com `AmazonS3ReadOnlyAccess`, mas `aula-04/laboratorio-parte2.md` instrui usar `LabInstanceProfile`, pois o Academy bloqueia criar roles. Esta implementação usa o profile existente com `LabRole`; não afirma que essa role tem apenas a policy pedida. A exigência literal de criar IAM permanece uma incompatibilidade a ser validada pelo professor.
- Tags comuns vêm de `default_tags`; cada recurso tagueável recebe `Name`. Associações de route table não suportam tags. Recursos IAM preexistentes pertencem ao Academy e não são alterados.

## Recursos criados

| Recurso | Função |
|---|---|
| VPC technova-vpc | Rede 10.0.0.0/16 com DNS |
| 2 subnets públicas | Acesso ao IGW, em duas AZs |
| 2 subnets privadas | Isolamento, em duas AZs |
| Internet Gateway | Acesso da rede pública à internet |
| Route table pública + 2 associações | Rota padrão para IGW |
| Route table padrão gerenciada | Somente rota local para privadas |
| Security Groups API e DB | Filtragem de tráfego |
| Key pair | Registro da chave pública SSH |
| EC2 + volume raiz gp2 de 8 GB | Amazon Linux 2023 e API Node.js |

## Evidências

Execução realizada em 17/09/2026 no AWS Academy: 14 recursos provisionados e destruídos, API respondendo em `/` e `/health`, Node.js v18.20.8 e identidade LabRole verificados via SSH. Foi usada a chave pública existente `~/.ssh/id_ed25519.pub`. Os arquivos `terraform-plan-output.txt`, `evidencia-plan.txt`, `evidencia-apply.txt`, `evidencia-api.json`, `evidencia-ssh.txt` e `evidencia-destroy.txt` contêm as saídas reais. Validação local não substitui execução no AWS Academy, cuja nota e percentual são conferidos pelo professor.
