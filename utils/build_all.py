import subprocess
import os

def run_powershell_script(script_path):
    try:
        result = subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        print(f"[SUCESSO] {script_path}:\n{result.stdout}")
    except subprocess.CalledProcessError as e:
        print(f"[ERRO] {script_path}:\n{e.stderr}")
        raise

def main():
    scripts = [
        os.path.join("lambda", "lambda_api", "build_api.ps1"),
        os.path.join("lambda", "lambda_db", "build_db.ps1"),
        os.path.join("lambda", "lambda_api_bronze", "build_processor.ps1"),
        os.path.join("lambda", "lambda_api_silver", "build_silver.ps1"),
        os.path.join("lambda", "lambda_categoria_bronze", "build_categoria_bronze.ps1"),
        os.path.join("lambda", "lambda_categoria_silver", "build_categoria_silver.ps1"),
        os.path.join("lambda", "lambda_silver_copy", "build_silver_copy.ps1")
    ]

    print("Iniciando empacotamento das Lambdas...")
    for script in scripts:
        run_powershell_script(script)
    print("Todos os pacotes foram gerados com sucesso.")

if __name__ == "__main__":
    main()
