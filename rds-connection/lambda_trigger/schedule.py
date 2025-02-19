import boto3
import sys
import logging
import pymysql
import json
import os

db_host = os.environ['RDS_HOST']
db_user = os.environ['DB_USER']
db_pass = os.environ['DB_PASS']
db_name = os.environ['DB_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(
        host=db_host,
        user=db_user,
        passwd=db_pass,
        db=db_name,
        connect_timeout=5
    )
    logger.info("Conexão com o banco de dados bem-sucedida!")
except pymysql.MySQLError as e:
    logger.error("Erro ao conectar ao banco de dados.")
    logger.error(e)
    raise

def lambda_handler(event, context):
    logger.info("Iniciando a atualização de pedidos para 'Enviado'")
    try:
        with conn.cursor() as cur:
            sql_update = """
                UPDATE PEDIDO 
                SET statusPedido = 'Enviado' 
                WHERE statusPedido = 'Em Processamento';
            """
            cur.execute(sql_update)
            conn.commit()
            logger.info("Pedidos 'Em Processamento' atualizados para 'Enviado'.")
    except Exception as e:
        logger.error("Erro ao atualizar pedidos.")
        logger.error(e)
        raise

    return {
        'statusCode': 200,
        'body': 'Pedidos atualizados para Enviado com sucesso!'
    }
