import requests  # Biblioteca para fazer requisições HTTP
import csv       # Biblioteca para manipular arquivos CSV
import time      # Biblioteca para adicionar pausas entre requisições

# Definir os termos de busca
SEARCH_TERMS = ["chromecast", "google home", "apple tv", "amazon fire tv"]
TOTAL_ITEMS = 150  # Número total de itens desejado
ITEMS_PER_REQUEST = 50  # Número de itens por requisição
BASE_SEARCH_URL = "https://api.mercadolibre.com/sites/MLA/search"
BASE_ITEM_URL = "https://api.mercadolibre.com/items/"

# Lista para armazenar os IDs dos produtos coletados
item_ids = []

# Buscar até 150 IDs de produtos
for term in SEARCH_TERMS:
    print(f"Buscando produtos para: {term}")
    offset = 0  # Controle da paginação

    while len(item_ids) < TOTAL_ITEMS:  # Continuar até atingir 150 IDs
        params = {"q": term, "limit": ITEMS_PER_REQUEST, "offset": offset}
        response = requests.get(BASE_SEARCH_URL, params=params)
        
        if response.status_code == 200:
            data = response.json()
            results = data.get("results", [])
            
            if not results:  # Se não houver mais resultados, sair do loop
                break
            
            # Adicionar IDs novos sem repetir
            for item in results:
                if item["id"] not in item_ids and len(item_ids) < TOTAL_ITEMS:
                    item_ids.append(item["id"])
            
            offset += ITEMS_PER_REQUEST  # Avançar para a próxima página
            
        else:
            print(f"Erro {response.status_code} ao buscar {term}")
            break  # Se der erro, sair do loop

print(f"Total de IDs coletados: {len(item_ids)}")  # Mostrar total de IDs coletados

# Buscar detalhes de cada item via API
items_data = []

for item_id in item_ids:
    item_url = f"{BASE_ITEM_URL}{item_id}"
    response = requests.get(item_url)
    
    if response.status_code == 200:
        item_details = response.json()
        
        # Criar um dicionário com os principais dados do produto
        item_info = {
            "ID": item_details.get("id"),
            "Titulo": item_details.get("title"),
            "Preco": item_details.get("price"),
            "Moeda": item_details.get("currency_id"),
            "Condicao": item_details.get("condition"),
            "Status": item_details.get("status"),
            "Data_Criacao": item_details.get("date_created"),
            "Ultima_Atualizacao": item_details.get("last_updated"),
            "Aceita_MercadoPago": item_details.get("accepts_mercadopago"),
            "Vendedor_ID": item_details.get("seller_id"),
            "Categoria_ID": item_details.get("category_id"),
            "Dominio": item_details.get("domain_id"),
            "Catalogo_Produto_ID": item_details.get("catalog_product_id"),
            "Cidade": item_details.get("seller_address", {}).get("city", {}).get("name", ""),
            "Estado": item_details.get("seller_address", {}).get("state", {}).get("name", ""),
            "Garantia": item_details.get("warranty"),
            "Link": item_details.get("permalink"),
        }
        
        items_data.append(item_info)
    
    else:
        print(f"Erro ao buscar item {item_id}: {response.status_code}")

    time.sleep(0.3)  # Pequena pausa para evitar bloqueio da API

# Salvar os dados coletados em um arquivo CSV
csv_filename = "mercadolivre_itens.csv"

with open(csv_filename, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=items_data[0].keys())
    writer.writeheader()
    writer.writerows(items_data)

print(f"Arquivo CSV '{csv_filename}' salvo com sucesso!")
