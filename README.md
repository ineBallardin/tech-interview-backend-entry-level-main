# Desafio técnico e-commerce

## Nossas expectativas

A equipe de engenharia da RD Station tem alguns princípios nos quais baseamos nosso trabalho diário. Um deles é: projete seu código para ser mais fácil de entender, não mais fácil de escrever.

Portanto, para nós, é mais importante um código de fácil leitura do que um que utilize recursos complexos e/ou desnecessários.

O que gostaríamos de ver:

- O código deve ser fácil de ler. Clean Code pode te ajudar.
- Notas gerais e informações sobre a versão da linguagem e outras informações importantes para executar seu código.
- Código que se preocupa com a performance (complexidade de algoritmo).
- O seu código deve cobrir todos os casos de uso presentes no README, mesmo que não haja um teste implementado para tal.
- A adição de novos testes é sempre bem-vinda.
- Você deve enviar para nós o link do repositório público com a aplicação desenvolvida (GitHub, BitBucket, etc.).

## O Desafio - Carrinho de compras
O desafio consiste em uma API para gerenciamento do um carrinho de compras de e-commerce.

Você deve desenvolver utilizando a linguagem Ruby e framework Rails, uma API Rest que terá 3 endpoins que deverão implementar as seguintes funcionalidades:

### 1. Registrar um produto no carrinho
Criar um endpoint para inserção de produtos no carrinho.

Se não existir um carrinho para a sessão, criar o carrinho e salvar o ID do carrinho na sessão.

Adicionar o produto no carrinho e devolver o payload com a lista de produtos do carrinho atual.


ROTA: `/cart`
Payload:
```json
{
  "product_id": 345, // id do produto sendo adicionado
  "quantity": 2, // quantidade de produto a ser adicionado
}
```

Response:
```json
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 345,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    },
    {
      "id": 346,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98,
    },
  ],
  "total_price": 7.96 // valor total no carrinho
}
```

### 2. Listar itens do carrinho atual
Criar um endpoint para listar os produtos no carrinho atual.

ROTA: `/cart`

Response:
```json
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 345,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    },
    {
      "id": 346,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98,
    },
  ],
  "total_price": 7.96 // valor total no carrinho
}
```

### 3. Alterar a quantidade de produtos no carrinho 
Um carrinho pode ter _N_ produtos, se o produto já existir no carrinho, apenas a quantidade dele deve ser alterada

ROTA: `/cart/add_item`

Payload
```json
{
  "product_id": 1230,
  "quantity": 1
}
```
Response:
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2, // considerando que esse produto já estava no carrinho
      "unit_price": 7.00, 
      "total_price": 14.00, 
    },
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90,
      "total_price": 9.90,
    },
  ],
  "total_price": 23.9
}
```

### 4. Remover um produto do carrinho 

Criar um endpoint para excluir um produto do do carrinho. 

ROTA: `/cart/:product_id`


#### Detalhes adicionais:

- Verifique se o produto existe no carrinho antes de tentar removê-lo.
- Se o produto não estiver no carrinho, retorne uma mensagem de erro apropriada.
- Após remover o produto, retorne o payload com a lista atualizada de produtos no carrinho.
- Certifique-se de que o endpoint lida corretamente com casos em que o carrinho está vazio após a remoção do produto.

### 5. Excluir carrinhos abandonados
Um carrinho é considerado abandonado quando estiver sem interação (adição ou remoção de produtos) há mais de 3 horas.

- Quando este cenário ocorrer, o carrinho deve ser marcado como abandonado.
- Se o carrinho estiver abandonado há mais de 7 dias, remover o carrinho.
- Utilize um Job para gerenciar (marcar como abandonado e remover) carrinhos sem interação.
- Configure a aplicação para executar este Job nos períodos especificados acima.

### Detalhes adicionais:
- O Job deve ser executado regularmente para verificar e marcar carrinhos como abandonados após 3 horas de inatividade.
- O Job também deve verificar periodicamente e excluir carrinhos que foram marcados como abandonados por mais de 7 dias.

### Como resolver

#### Implementação
Você deve usar como base o código disponível nesse repositório e expandi-lo para que atenda as funcionalidade descritas acima.

Há trechos parcialmente implementados e também sugestões de locais para algumas das funcionalidades sinalizados com um `# TODO`. Você pode segui-los ou fazer da maneira que julgar ser a melhor a ser feita, desde que atenda os contratos de API e funcionalidades descritas.

#### Testes
Existem testes pendentes, eles estão marcados como <span style="color:green;">Pending</span>, e devem ser implementados para garantir a cobertura dos trechos de código implementados por você.
Alguns testes já estão passando e outros estão com erro. Com a sua implementação os testes com erro devem passar a funcionar. 
A adição de novos testes é sempre bem-vinda, mas sem alterar os já implementados.


### O que esperamos
- Implementação dos testes faltantes e de novos testes para os métodos/serviços/entidades criados
- Construção das 4 rotas solicitadas
- Implementação de um job para controle dos carrinhos abandonados


### Itens adicionais / Legais de ter
- Utilização de factory na construção dos testes
- Desenvolvimento do docker-compose / dockerização da app

A aplicação já possui um Dockerfile, que define como a aplicação deve ser configurada dentro de um contêiner Docker. No entanto, para completar a dockerização da aplicação, é necessário criar um arquivo `docker-compose.yml`. O arquivo irá definir como os vários serviços da aplicação (por exemplo, aplicação web, banco de dados, etc.) interagem e se comunicam.

- Adicione tratamento de erros para situações excepcionais válidas, por exemplo: garantir que um produto não possa ter quantidade negativa. 

- Se desejar você pode adicionar a configuração faltante no arquivo `docker-compose.yml` e garantir que a aplicação rode de forma correta utilizando Docker. 

## Informações técnicas

### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15

### Como executar o projeto

## Executando com Docker (Recomendado)

### E-commerce CLI
Para facilitar o desenvolvimento, use nosso CLI customizado:

```bash
# Iniciar todos os serviços
bin/ecommerce-cli up

# Executar testes
bin/ecommerce-cli rspec                           # Todos os testes
bin/ecommerce-cli rspec spec/models/cart_spec.rb  # Teste específico

# Comandos Rails
bin/ecommerce-cli rails db:migrate
bin/ecommerce-cli rails db:seed
bin/ecommerce-cli console

# Outros comandos úteis
bin/ecommerce-cli stop        # Parar serviços (manter containers)
bin/ecommerce-cli down        # Parar serviços e remover containers
bin/ecommerce-cli build       # Rebuildar todos os serviços
bin/ecommerce-cli build web   # Rebuildar serviço específico
bin/ecommerce-cli sidekiq     # Executar Sidekiq worker
bin/ecommerce-cli bash        # Bash no container
bin/ecommerce-cli logs        # Ver logs

# Ver todos os comandos
bin/ecommerce-cli help
```

### Comandos Docker tradicionais
Se preferir usar Docker Compose diretamente:

```bash
# Iniciar serviços
docker compose up -d

# Executar testes
docker compose run --rm test bundle exec rspec

# Console Rails
docker compose run --rm web bundle exec rails console
```

## Executando a app sem o docker
Dado que todas as as ferramentas estão instaladas e configuradas:

Instalar as dependências do:
```bash
bundle install
```

Executar o sidekiq:
```bash
bundle exec sidekiq
```

Executar projeto:
```bash
bundle exec rails server
```

Executar os testes:
```bash
bundle exec rspec
```

## Testando a API via Postman

### Preparando o ambiente
Primeiro, certifique-se de que a aplicação está rodando:

```bash
# Com CLI customizado
bin/ecommerce-cli up
bin/ecommerce-cli rails db:seed

# Ou com Docker Compose
docker compose up -d
docker compose run --rm web bundle exec rails db:seed
```

A aplicação estará disponível em: `http://localhost:3000`

### Endpoints implementados

#### 1. GET /cart - Listar itens do carrinho
- **URL:** `GET http://localhost:3000/cart`
- **Headers:** `Content-Type: application/json`
- **Response:** Retorna o carrinho atual da sessão

#### 2. POST /cart - Adicionar produto no carrinho (apenas novos)
- **URL:** `POST http://localhost:3000/cart`
- **Headers:** `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "product_id": 1,
  "quantity": 2
}
```
- **Nota:** Se o produto já existe no carrinho, retorna erro 409. Use `/cart/add_item` para atualizar quantidade.

#### 3. POST /cart/add_item - Adicionar/atualizar quantidade do produto
- **URL:** `POST http://localhost:3000/cart/add_item`
- **Headers:** `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "product_id": 1,
  "quantity": 3
}
```
- **Nota:** Se o produto já existe, soma a quantidade. Se não existe, adiciona ao carrinho.

#### 4. DELETE /cart/:product_id - Remover produto do carrinho
- **URL:** `DELETE http://localhost:3000/cart/1`
- **Headers:** `Content-Type: application/json`
- **Nota:** Substitua `:product_id` pelo ID do produto que deseja remover.

### Produtos disponíveis (via db:seed)
Após executar `rails db:seed`, os seguintes produtos estarão disponíveis:

| ID | Nome | Preço |
|----|------|-------|
| 1 | Samsung Galaxy S24 Ultra | R$ 12999.99 |
| 2 | iPhone 15 Pro Max | R$ 14999.99 |
| 3 | Xiamo Mi 27 Pro Plus Master Ultra | R$ 999.99 |

### Fluxo de teste sugerido

1. **Listar carrinho vazio:**
   - GET `/cart`

2. **Adicionar primeiro produto:**
   - POST `/cart` com `{"product_id": 1, "quantity": 2}`

3. **Tentar adicionar mesmo produto novamente (erro esperado):**
   - POST `/cart` com `{"product_id": 1, "quantity": 1}` - deve retornar 409

4. **Atualizar quantidade do produto existente:**
   - POST `/cart/add_item` com `{"product_id": 1, "quantity": 1}` - quantidade vira 3

5. **Adicionar segundo produto:**
   - POST `/cart/add_item` com `{"product_id": 2, "quantity": 1}`

6. **Verificar carrinho:**
   - GET `/cart` - deve mostrar 2 produtos

7. **Remover um produto:**
   - DELETE `/cart/1`

8. **Verificar carrinho final:**
   - GET `/cart` - deve mostrar apenas 1 produto

### Como enviar seu projeto
Salve seu código em um versionador de código (GitHub, GitLab, Bitbucket) e nos envie o link publico. Se achar necessário, informe no README as instruções para execução ou qualquer outra informação relevante para correção/entendimento da sua solução.
