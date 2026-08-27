# Análise do Uso de IA — Aula 02 TF

## Prompt Utilizado

> "Crie um docker-compose.yml para uma aplicação Node.js 20 com Express que usa PostgreSQL 15 como banco de dados e Redis 7 como cache. A API roda na porta 3000. O PostgreSQL precisa de volume nomeado para persistência. Todos os serviços devem estar na mesma rede bridge customizada. Use variáveis de ambiente com interpolação de arquivo .env. Adicione healthchecks, depends_on com condition, e restart policy unless-stopped."

## Output Original do Kiro

```yaml
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: technova
      REDIS_HOST: redis
      REDIS_PORT: 6379
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: technova
      POSTGRES_USER: technova
      POSTGRES_PASSWORD: technova_tf_2024
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  postgres-data:
```

## Alterações que Fiz Manualmente

| O que mudei | Por quê |
|---|---|
| Substituí valores fixos por `${VARIAVEL}` | Mantém credenciais e configurações no `.env`, sem hardcode no Compose. |
| Criei `.env.example` | Permite reproduzir o ambiente sem publicar a senha local. |
| Adicionei healthchecks no PostgreSQL e Redis | Garante que os serviços estejam prontos antes de a API iniciar. |
| Troquei a lista simples de `depends_on` por condições `service_healthy` | A API passa a aguardar banco e cache saudáveis. |
| Criei a rede `technova-network` e liguei os três serviços | Atende ao isolamento e à comunicação interna exigidos. |
| Adicionei `restart: unless-stopped` aos três serviços | Faz os containers se recuperarem de reinicializações não intencionais. |
| Mapeei a porta com `${PORT}` | A porta externa também pode ser configurada pelo `.env`. |
| Incluí comentários por seção no arquivo final | Deixa o papel de cada configuração explícito para manutenção. |

## O que o Kiro Acertou

- Propôs os três serviços corretos: API, PostgreSQL e Redis.
- Selecionou as imagens `postgres:15-alpine` e `redis:7-alpine`.
- Incluiu o volume nomeado para a persistência do PostgreSQL.
- Usou os nomes de host dos serviços (`postgres` e `redis`), que funcionam pela resolução DNS da rede Docker.

## O que o Kiro Errou ou Omitiu

- Expôs senha e demais configurações diretamente no Compose.
- Não criou uma rede bridge customizada.
- Não adicionou healthchecks para banco ou cache.
- O `depends_on` sem condições verifica apenas a ordem de inicialização, não a disponibilidade dos serviços.
- Não configurou a política de reinício.
- Fixou a porta `3000` em vez de interpolá-la a partir do `.env`.

## Minha Avaliação

- **Tempo economizado usando IA:** aproximadamente 20 minutos para obter a estrutura inicial.
- **Tempo gasto validando/corrigindo:** aproximadamente 25 minutos.
- **Nota para o output da IA (1-10):** 6/10.
- **Usaria novamente para este tipo de tarefa?** Sim. A IA acelera o rascunho, mas a validação dos requisitos, da segurança das variáveis e do comportamento do Docker Compose continua sendo responsabilidade de quem desenvolve.
