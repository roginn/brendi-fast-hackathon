A feature de consultor de negócio segue as etapas:

## 1. Criação de métricas e indicadores
Usando um LLM, o consultor de negócio faz um brainstorming de métricas agregadas que seriam úteis para o negócio. Em seguida, ele roda queries no banco para extrair os dados necessários para as métricas.

As métricas são consolidadas a partir dos dados do banco, e o resultado é simples de ser lido.

Por exemplo:
- Número de pedidos, agregados por dia, semana, mês, etc.
- Receita, agregada por dia, semana, mês, etc.
- Ticket médio, agregado por dia, semana, mês, etc.

Para criar métricas, o consultor se baseia na documentação em `prd/indicadores.md`.

Cada uma dessas métricas deve ser salva no banco de dados, tabela `aggregated_metrics` com os atributos:
- timestamp da criação
- nome da métrica
- SQL query para extrair os dados
- resultado da métrica em JSON (numa coluna jsonb do Postgres)

## 2. Análise de dados
Para cada indicador, análise e ação em `prd/indicadores.md`, o consultor de negócio cria uma recomendação de ação. Para isso, a cada análise, eles carrega todas as métricas que criou no passo 1 e inclui no contexto do LLM.

## 3. Sugestões de ações

## 4. Relatórios e dashboards

## 5. Integração com outras ferramentas

## 6. Treinamento e suporte

## 7. Melhorias contínuas