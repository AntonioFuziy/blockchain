# Plataforma de ticket v0.0.7

# Dicionário que indica se o usuário comprou um ticket
# Se retornar 0, o usuário não possui ticket
users: public(HashMap[address, uint256])
# Valor do ingresso
price: uint256

# Endereço do dono do contrato
owner: address

# Número máximo de tickets
limit: uint256
# Número de tickets emitidos
count: uint256

# Função que roda quando é feito o deploy do contrato
@external
def __init__(price: uint256, limit: uint256):
    # Guarda o Endereço do dono do contrato na variável
    self.owner = msg.sender
    self.price = price
    self.limit = limit
    self.count = 0

@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def buy():
    # Testa se o comprador já não comprou
    assert self.users[msg.sender] == 0
    
    # Testa se o valor passado ao contrato foi suficiente
    assert msg.value >= self.price
    
    # Testa se ainda há tickets sobrando
    assert self.count <= self.limit
    
    # Preenche o dicionário com 1 no endereço de quem chamou a função
    # msg.sender existe para toda função e não precisa entrar como argumento
    self.users[msg.sender] = 1
    
    self.count += 1 # Soma 1 se finalizar a compra
    
@external
def change_price(price: uint256):
    # Testa se é o dono do contrato
    assert msg.sender == self.owner
    
    # Altera o preço
    self.price = price

# A função não precisa ser payable
@external
def cancel():
    # Testa se o comprador já comprou
    assert self.users[msg.sender] == 1
    
    # Anula a compra
    self.users[msg.sender] = 0
    # Subtrai 1 do contador de ingressos
    self.count -= 1
    # Devolve 80% do dinheiro (todos os valores tem que ser inteiros)
    send(msg.sender, self.price*80/100)
    
