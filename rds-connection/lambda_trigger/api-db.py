import boto3
import sys
import logging
import pymysql
import json
import os
import uuid

user_name = os.environ['DB_USER']
password = os.environ['DB_PASS']
rds_proxy_host = os.environ['RDS_HOST']
db_name = os.environ['DB_NAME']

sqs_queue_url = os.environ['SQS_QUEUE_URL']
sqs_client = boto3.client('sqs')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(
        host=rds_proxy_host,
        user=user_name,
        passwd=password,
        db=db_name,
        connect_timeout=5
    )
    logger.info("SUCCESS: Connection to RDS for MySQL instance succeeded")
except pymysql.MySQLError as e:
    logger.error("ERROR: Could not connect to MySQL instance.")
    logger.error(e)
    sys.exit(1)

sql_table = """
    CREATE TABLE IF NOT EXISTS PEDIDO (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cliente VARCHAR(255) NOT NULL,
        rua VARCHAR(255) NOT NULL,
        numero INT NOT NULL,
        bairro VARCHAR(255) NOT NULL,
        complemento VARCHAR(255),
        descricao TEXT NOT NULL,
        pagamento TEXT NOT NULL,
        statusPedido VARCHAR(50) NOT NULL
    );
"""

with conn.cursor() as cur:
    cur.execute(sql_table)
    conn.commit()

def lambda_handler(event, context):
    logger.info("Recebendo requisição...")

    try:
        body = json.loads(event.get("body", "{}"))
        logger.info(f"Dados recebidos: {body}")
    except Exception as e:
        logger.error("Erro ao processar JSON da requisição.")
        logger.error(str(e))
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Requisição inválida"})
        }

    logger.info("Preparando para inserir os dados no banco...")

    try:
        with conn.cursor() as cur:
            
            cliente = body.get("nome")
            rua = body.get("rua")
            numero = body.get("numero")
            bairro = body.get("bairro")
            complemento = body.get("complemento")
            descricao = body.get("pedido")
            pagamento = body.get("pagamento")
            statusPedido = "Recebido"

            sql_insert = """
                INSERT INTO PEDIDO (cliente, rua, numero, bairro, complemento, descricao, pagamento, statusPedido)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
            """
            cur.execute(sql_insert, (cliente, rua, numero, bairro, complemento, descricao, pagamento, statusPedido))
            pedido_id = cur.lastrowid 
            conn.commit()

        logger.info("Dados inseridos no banco com sucesso!")
    except Exception as e:
        logger.error("Erro ao inserir dados no banco de dados.")
        logger.error(str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Erro ao inserir pedido no banco"})
        }

    logger.info("Enviando mensagem para SQS...")

    try:
        sqs = boto3.client('sqs', region_name='sa-east-1')
        queue_url = os.environ['SQS_QUEUE_URL']
        # message_body = json.dumps(body)
        logger.info("Conexão com SQS com sucesso!")

        message_body = {
            "id": pedido_id,
            "nome": cliente,
            "rua": rua,
            "numero": numero,
            "bairro": bairro,
            "complemento": complemento,
            "pedido": descricao,
            "pagamento": pagamento,
            "statusPedido": statusPedido
        }

        logger.info("Body para o SQS:")
        logger.info(message_body)

        response = sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(message_body),
            MessageGroupId="default",
            MessageDeduplicationId=str(uuid.uuid4())
        )

        logger.info(f"Mensagem enviada para a SQS com ID: {response['MessageId']}")
    except Exception as e:
        logger.error("Erro ao enviar mensagem para SQS.")
        logger.error(str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Erro ao enviar mensagem para fila SQS"})
        }

    logger.info("Finalizando execução da Lambda...")

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps({"message": "Pedido cadastrado e enviado para a fila com sucesso!"})
    }