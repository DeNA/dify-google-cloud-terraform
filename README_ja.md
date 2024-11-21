# Terraform for Dify on Google Cloud

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-1.9.5-blue.svg)


![Dify GCP Architecture](images/dify-google-cloud-architecture.png)

<a href="../../"><img alt="README in English" src="https://img.shields.io/badge/English-d9d9d9"></a>

## 概要
本レポジトリでは、Terraform により自動で Google Cloud のリソースを立ち上げ、Dify を高可用構成でデプロイすることが可能です。

## 特徴
- サーバーレスホスティング
- オートスケール
- データ永続化

## 事前準備
- Google Cloud アカウント
- Terraform インストール済み
- gcloud CLI インストール済み
- 必要なAPIの有効化 (Serverless VPC Access, Service Networking, etc.)

## 設定
- `terraform/environments/dev/terraform.tfvars` ファイルで環境固有の値を設定します。
- terraform stateを管理する用のGCSバケットを事前に作成し、`terraform/environments/dev/provider.tf` ファイルの "your-tfstate-bucket" を作成したバケット名に書き換えます。

## 始め方
1. リポジトリをクローン:
    ```sh
    git clone https://github.com/DeNA/dify-google-cloud-terraform.git
    ```

2. Terraformを初期化:
    ```sh
    cd terraform/environments/dev
    terraform init
    ```

3. Artifact Registry リポジトリを作成:
    ```sh
    terraform apply -target=module.registry
    ```

4. コンテナイメージをビルド＆プッシュ:
    ```sh
    cd ../../..
    sh ./docker/cloudbuild.sh <your-project-id> <your-region>
    ```
    また、dify-api イメージのバージョンを指定することもできます。
    ```sh
    sh ./docker/cloudbuild.sh <your-project-id> <your-region> <dify-api-version>
    ```
    バージョンを指定しない場合、デフォルトで最新バージョンが使用されます。

5. Terraformをプランニング:
    ```sh
    cd terraform/environments/dev
    terraform plan
    ```

6. Terraformを適用:
    ```sh
    terraform apply
    ```


## リソースの削除
```sh
terraform destroy
```

注意: Cloud Storage、Cloud SQL、VPC、およびVPC Peeringは `terraform destroy` コマンドで削除できません。これらはデータ永続化のための重要なリソースです。コンソールにアクセスして慎重に削除してください。その後、`terraform destroy` コマンドを使用してすべてのリソースが削除されたことを確認できます。

## 参照
- [Dify](https://dify.ai/)
- [GitHub](https://github.com/langgenius/dify)

## ライセンス
このソフトウェアはMITライセンスの下でライセンスされています。詳細はLICENSEファイルを参照してください。
