# Aula 03 — Terraform + IAM | Andreyh Rodrigues de Souza (RA: 6325231)

## Design da Estrutura IAM

- **`technova-developers`**: Grupo destinado aos desenvolvedores que precisam apenas consultar/ler dados no S3 (`s3:GetObject`, `s3:ListBucket`).
- **`technova-platform-eng`**: Grupo para a engenharia de plataforma que consulta e inicia/para instâncias EC2 identificadas com `Project = TechNova`, além de ler e gravar nos buckets TechNova.
- **Separação de Responsabilidades**: O usuário `juliana` possui permissões estritamente de desenvolvimento, enquanto `rafael` faz parte de ambos os grupos para atuar na sustentação da plataforma. O usuário `lucas` está no grupo de devs com restrições explícitas de remoção.

## Princípio do Menor Privilégio

O princípio estabelece que cada usuário ou serviço deve possuir apenas o nível mínimo de acesso necessário para desempenhar sua função.

1. **Restrição por nome de recurso**: A policy de leitura limita a ação `s3:GetObject` somente para buckets prefixados com `technova-*`, impedindo o acesso a outros buckets da conta.
2. **Uso de Conditions**: As ações de `Start`/`Stop` no EC2 só são autorizadas se a instância possuir a tag `Project = TechNova`.

*Se utilizássemos `AmazonS3FullAccess`, os desenvolvedores teriam acesso administrativo total aos buckets de dados, podendo deletar logs, bases de dados ou tornar buckets públicos acidentalmente.*

O `Deny` explícito de `s3:Delete*` e `ec2:Terminate*` é anexado ao grupo developers. Como Rafael está nos dois grupos, ele também recebe esse bloqueio: no IAM, um `Deny` sempre prevalece sobre qualquer `Allow`. Por isso, a policy da plataforma oferece leitura e escrita, sem remoção de objetos ou término de instâncias.

## Tags e Limitação do IAM

As tags obrigatórias (`Project`, `ManagedBy`, `Aluno`, `RA`, `Disciplina` e `Aula`) são aplicadas a todos os recursos deste exercício que aceitam tags: usuários, policies, role e instance profile. A API IAM da AWS não oferece suporte a tags para `aws_iam_group`, associações de grupos ou anexos de policy; portanto, não há como adicionar `tags` a esses recursos no Terraform sem produzir uma configuração inválida. A tag adicional `Environment` usa a variável reutilizável `environment`.

## Diagrama de Permissões

```text
[juliana]    ──> [technova-developers]   ──> [s3-read Policy] ──> S3 (technova-*)
[lucas]      ──> [technova-developers]   ──> [deny-destructive] ──x Delete/Terminate

[rafael]     ──> [technova-developers]
             ──> [technova-platform-eng] ──> [ec2-s3-full Policy] ──> EC2 (Tag: TechNova) + S3

[EC2 Instance] ──> [ec2-profile] ──> [ec2-role] ──> S3 (technova-app-data-*)
```

## Comandos Utilizados

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Reflexão

Criar IAM pelo Console é útil para aprendizado, mas depende de ações manuais e é difícil revisar cada mudança depois. Com Terraform, as permissões ficam versionadas, revisáveis em pull requests e reproduzíveis; o `plan` permite conferir os recursos antes de alterá-los. Isso torna a equipe mais auditável e reduz o risco de permissões criadas por engano.
