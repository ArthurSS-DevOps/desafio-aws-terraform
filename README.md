# AWS Terraform Challenge 

Este projeto foi desenvolvido como parte de um desafio técnico com o objetivo de demonstrar conhecimentos práticos em **AWS**, **Terraform** e **Infrastructure as Code (IaC)**.

A ideia aqui não foi apenas “fazer funcionar”, mas construir uma pequena arquitetura cloud totalmente automatizada, onde toda a infraestrutura é criada utilizando Terraform, sem necessidade de configurar recursos manualmente no console da AWS.

A solução também foi planejada para funcionar dentro dos limites do **AWS Free Tier**, permitindo que o ambiente seja executado e testado sem gerar custos inesperados.

---

# Arquitetura da Solução

A infraestrutura provisionada cria automaticamente uma pequena arquitetura composta por um frontend estático, um backend containerizado e uma rotina automatizada.

Internet
   │
   ▼
S3 (Frontend estático)
   │
   ▼
EC2 (Backend com Docker)
   │
   ▼
EventBridge (Agendamento)
   │
   ▼
Lambda (Rotina automatizada)
   │
   ▼
S3 (Armazenamento dos arquivos gerados)

Essa arquitetura demonstra como diferentes serviços da AWS podem trabalhar juntos e como o Terraform pode ser utilizado para criar um ambiente reproduzível e automatizado.

---

# Frontend Estático

O frontend da aplicação é hospedado utilizando **Amazon S3 com Static Website Hosting**.

Durante o provisionamento, o Terraform cria automaticamente:

- Um bucket S3 dedicado ao frontend
- A configuração de Static Website Hosting
- O upload automático do arquivo `index.html`
- Uma policy pública permitindo acesso ao site

O objetivo aqui foi demonstrar como hospedar um site estático de forma simples e automatizada, sem necessidade de servidores.

---

# Backend Containerizado

O backend é executado em uma instância EC2 configurada automaticamente durante o provisionamento.

Configuração utilizada:

- Instância **t3.micro** (compatível com o Free Tier)
- Instalação automática do **Docker** via `user_data`
- Execução de um container **Nginx**
- Porta **3000** exposta para acesso externo

Essa etapa demonstra como inicializar automaticamente uma aplicação containerizada durante a criação da infraestrutura.

---

# Rotina Automatizada (Serverless)

O projeto também inclui uma pequena rotina automatizada utilizando serviços serverless da AWS.

Componentes utilizados:

- **AWS Lambda (Python 3.9)**
- **Amazon EventBridge** para agendamento
- **Amazon S3** para armazenar os arquivos gerados

Funcionamento da rotina:

1. O EventBridge executa a função Lambda diariamente as 10 Horas (UTC-3).
2. A função gera um arquivo contendo o timestamp da execução.
3. O arquivo é salvo em um bucket S3 específico.

Esse tipo de fluxo é comum em ambientes cloud, sendo utilizado por exemplo para geração automática de relatórios, logs ou processamento agendado de dados.

---

# Estrutura do Projeto

aws-terraform-challenge/

├── provider.tf  
├── variables.tf  
├── main.tf  
├── outputs.tf  

├── frontend/  
│   └── index.html  

├── lambda/  
│   ├── lambda_function.py  
│   └── lambda_function.zip  

└── README.md

A estrutura foi organizada para manter separação clara entre:

- infraestrutura
- frontend
- código da função Lambda

Isso ajuda a manter o projeto mais fácil de entender e manter.

---

# Pré-requisitos

Para executar este projeto você precisa ter:

- Conta ativa na **AWS**
- **Terraform** instalado
- **AWS CLI** configurado

Configuração das credenciais AWS:

aws configure

Ou utilizando variáveis de ambiente:

AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  
AWS_DEFAULT_REGION

---

#  Permissões AWS necessárias

Durante a execução do `terraform apply`, o Terraform cria diversos recursos automaticamente.

Entre eles:

- Buckets no Amazon S3
- Instâncias no Amazon EC2
- Funções no AWS Lambda
- Regras de agendamento no Amazon EventBridge
- Roles no AWS IAM

Para evitar problemas de permissão durante o provisionamento, a forma mais simples de executar o projeto em ambiente de testes é utilizar um usuário AWS com a policy:

AdministratorAccess

Em ambientes mais restritos (como contas corporativas), o usuário precisará pelo menos de permissões relacionadas a:

ec2:*  
s3:*  
lambda:*  
events:*  
iam:CreateRole  
iam:AttachRolePolicy  
iam:PassRole  

Caso a conta utilize **Service Control Policies (SCP)** ou **Permissions Boundaries**, essas políticas também precisam permitir a criação desses recursos.

---

#  Como Executar

Na raiz do projeto execute:

terraform init  
terraform plan  
terraform apply  

Após o `apply`, o Terraform exibirá:

- URL do frontend hospedado no S3
- IP público da instância EC2

---

#  Testando a Rotina Automatizada

A rotina pode ser testada manualmente através do console da AWS.

Passos:

1. Acesse o serviço **AWS Lambda**
2. Abra a função criada pelo Terraform
3. Execute a função utilizando **Test / Invoke**

Após a execução, um arquivo será criado no bucket S3 responsável pela rotina.

---

#  Como Destruir a Infraestrutura

Para remover todos os recursos criados:

terraform destroy

Esse comando remove completamente toda a infraestrutura provisionada pelo projeto.

---

#  Sobre o Terraform State

Os arquivos de estado do Terraform **não devem ser versionados no Git**.

Por isso o projeto utiliza `.gitignore` para ignorar arquivos como:

terraform.tfstate  
terraform.tfstate.backup  
.terraform/  

Em ambientes reais, o estado do Terraform normalmente é armazenado em **remote state**, como por exemplo em um bucket S3.

---

#  Custos

A arquitetura foi planejada para funcionar dentro do **AWS Free Tier**:

- EC2 t3.micro (até 750 horas/mês)
- Lambda (1 milhão de execuções/mês)
- EventBridge (1 milhão de eventos/mês)
- S3 (até 5GB de armazenamento)

Serviços como **Load Balancer**, **NAT Gateway** ou **RDS** não foram utilizados justamente para evitar custos adicionais.

---

#  Decisões Técnicas

Algumas decisões foram tomadas pensando em boas práticas:

- Uso de `random_id` para evitar conflitos globais de nomes de bucket
- Uso de variáveis de ambiente na Lambda
- Separação dos arquivos Terraform para melhor organização
- Provisionamento completo via Terraform
- Infraestrutura reproduzível em qualquer conta AWS

---

#  Objetivo do Projeto

Demonstrar:

- Conhecimento prático em AWS
- Uso de Terraform para Infrastructure as Code
- Estruturação organizada de infraestrutura
- Automação de provisionamento
- Integração entre múltiplos serviços AWS

---

#  Autor

Arthur De Sousa Silva

Projeto desenvolvido como parte de estudo e prática na área de **Cloud / DevOps**.

---

Contribuições, sugestões e melhorias são sempre bem-vindas 