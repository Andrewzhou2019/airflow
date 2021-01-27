from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

#default arguments that get included in all operators
default_args = {
    'owner': 'airflow',
    'retries': 3,
    'retry_delay': timedelta(seconds=30)
}

dag = DAG(
    dag_id='my_dag',
    description='First DAG',
    start_date=datetime(2020,9,1),
    schedule_interval='0 0 * * *',
    catchup=False,
    default_args=default_args
)

#operators
task_1 = BashOperator(
    task_id='echo_task',
    bash_command='echo "Hello from task_1"',
    dag=dag
)

task_2 = BashOperator(
   task_id='cat_task',
   bash_command='cat /etc/hosts',
   dag=dag
)

#Define directional dependencies on the tasks
task_1 >> task_2

