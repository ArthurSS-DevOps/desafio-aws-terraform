# AWS Terraform Challenge 🚀

Este projeto foi desenvolvido como parte de um desafio técnico com o objetivo de demonstrar conhecimentos em **AWS, Terraform e práticas de Infrastructure as Code (IaC)**.

A ideia aqui não foi apenas "fazer funcionar", mas construir algo organizado, reproduzível e próximo do que encontramos em um ambiente real.

Todos os recursos utilizados estão dentro do **AWS Free Tier**, evitando custos desnecessários.

---

# 📐 O que foi construído

A solução provisiona automaticamente três componentes principais:

## 🖥️ Frontend Estático

* Amazon S3 com Static Website Hosting
* Upload automático do `index.html`
* Acesso público configurado via policy

Um frontend simples, mas totalmente provisionado via Terraform — nada criado manualmente no console.

---

## 🐳 Backend Containerizado

* EC2 t2.micro (Free Tier)
* Docker instalado automaticamente via `user_data`
* Container Nginx rodando na porta 80 do container e exposto na porta 3000 da instância.

Aqui a intenção foi demonstrar automação de infraestrutura + bootstrap da aplicação já no provisionamento.

---

## ⏰ Rotina Automatizada

* AWS Lambda (Python 3.9)
* Amazon EventBridge configurado para executar diariamente às **10:00 (UTC-3)**
* Bucket S3 para armazenar arquivos gerados
* Arquivo criado com timestamp da execução

A execução ocorre todos os dias às 10 horas no fuso UTC-3, simulando uma rotina automática de geração de relatório.

Essa parte demonstra integração entre serviços, agendamento automatizado e arquitetura orientada a eventos.

---

# 🧱 Estrutura do Projeto

```
aws-terraform-challenge/
│
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
│
├── frontend/
│   └── index.html
│
└── lambda/
    ├── lambda_function.py
    └── lambda_function.zip
```

A separação dos arquivos foi feita para manter organização e facilitar manutenção futura.

---

# ⚙️ Pré-requisitos

Para executar o projeto você precisa:

* Terraform instalado
* Conta AWS ativa
* Credenciais configuradas (AWS CLI ou variáveis de ambiente)

Exemplo:

```
aws configure
```

---

# 🚀 Como Executar

Na raiz do projeto:

```
terraform init
terraform plan
terraform apply
```

Ao final do `apply`, o Terraform exibirá:

* URL do frontend (S3)
* IP público da instância EC2

Tudo provisionado automaticamente.

---

# 🧹 Como Destruir os Recursos

Para evitar qualquer custo após testes:

```
terraform destroy
```

---

# 💰 Sobre custos

A arquitetura foi pensada para operar dentro dos limites do AWS Free Tier:

* EC2 t2.micro (750 horas/mês)
* Lambda (1 milhão de execuções/mês)
* EventBridge (1 milhão de eventos/mês)
* S3 (5GB armazenamento)

Serviços como Load Balancer, NAT Gateway e RDS não foram utilizados justamente para evitar cobrança.

---

# 🧠 Decisões Técnicas

Algumas escolhas foram feitas pensando em boas práticas:

* Uso de `random_id` para evitar conflitos globais de nomes no S3
* Uso de variáveis de ambiente na Lambda (evitando valores hardcoded)
* Separação dos arquivos Terraform para melhor organização
* Provisionamento 100% automatizado

A proposta foi demonstrar clareza, organização e entendimento da arquitetura — não apenas subir recursos.

---

# 🎯 Objetivo do Projeto

Demonstrar:

* Conhecimento em AWS
* Uso prático de Terraform
* Estruturação organizada de infraestrutura
* Automação real de provisionamento
* Boas práticas iniciais de arquitetura

---

# 👨‍💻 Autor

Arthur De Sousa Silva

Projeto desenvolvido como parte de desafio técnico na área de Cloud / DevOps.

---

Se quiser executar, testar ou sugerir melhorias, fique à vontade 🙂
