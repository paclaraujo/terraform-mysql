# Terraform

Máquina virtual usando Ubuntu e MySQL e provisionada pelo Terraform no ambiente Azure.

## Pré Requisitos

Para rodar este projeto são necessárias as seguintes instalações: 

- [Terraform](https://www.terraform.io/)
- [Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli)

## Instalação

Após instalação do Terraform e da Azure CLI, execute os seguintes comandos para rodar o projeto localmente:

Clone o projeto em sua máquina:
```sh
git clone https://github.com/paclaraujo/terraform-mysql
```

Faça login em sua conta azure:
```sh
az login
```

Inicie o repositório com o terraform:
```sh
terraform init
```

Visualize as alterações que serão executadas pelas configurações atuais do repositório:
```sh
terraform plan
```

Crie ou atualize a infraestrutura:
```sh
terraform apply
```

## Acessado a máquina virtual a partir do terminal

Para acessar a máquina virtual através do terminal execute o comando:

```sh
ssh adminadmin@<tf-mysql-public-ip>
```

**Obs**: Para localizar o Public IP criado por essa máquina virtual acesse o seu portal `azure > resource groups > terraform-mysql > tf-mysql-public-ip >` IP Address.

**Obs2**:A senha que será solicitada é a senha configurada no arquivo `terraform.tfvars`.

## Acessado a o mysql pela vm

Após rodar o comando anterior execute:

```sh
mysql -u root -proot
```

## Tecnologias usadas

- [Terraform](https://www.terraform.io/)
- [Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli)
- [Azure](https://azure.microsoft.com/pt-br/)

## Autora

* **Paloma Araujo** - [@paclaraujo](https://github.com/paclaraujo)