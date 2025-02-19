import boto3
import sys
import logging
import pymysql
import json
import os

DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
RDS_HOST = os.environ['RDS_HOST']
DB_NAME = os.environ['DB_NAME']

SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
sqs_client = boto3.client('sqs')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(
        host=RDS_HOST,
        user=DB_USER,
        passwd=DB_PASS,
        db=DB_NAME,
        connect_timeout=5
    )
    logger.info("Conexão com o banco de dados bem-sucedida!")
except pymysql.MySQLError as e:
    logger.info("Erro ao conectar ao banco de dados:", e)
    raise e


def lambda_handler(event, context):
    logger.info(f"Recebendo mensagem da fila SQS...")
    
    for record in event['Records']:
        body = json.loads(record['body'])
        pedido_id = body.get("id")

        if not pedido_id:
            logger.error("ID do pedido não encontrado na mensagem.")
            continue

        logger.info(f"Atualizando pedido {pedido_id} para 'Em Processamento'.")

        try:
            with conn.cursor() as cur:
                sql_update = "UPDATE PEDIDO SET statusPedido = %s WHERE id = %s;"
                cur.execute(sql_update, ("Em Processamento", pedido_id))
                conn.commit()
            
            logger.info(f"Pedido {pedido_id} atualizado para 'Em Processamento'.")

        except Exception as e:
            logger.error(f"Erro ao atualizar pedido {pedido_id}: {str(e)}")
            continue

    return {
        "statusCode": 200,
        "body": "Mensagens processadas com sucesso."
    }