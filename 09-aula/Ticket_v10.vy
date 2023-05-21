# Plataforma de ticket v0.1.0

# Struct que agrupa os dados de um ingresso
struct Passport:
  owner: address # Dono do ingresso
  price: uint256 # Valor do ingresso
  valid: bool # Indicação se o ingresso está válido ou não


# Dicionário que indica se o usuário comprou um ticket
users: public(HashMap[address, Passport])

# Valor do ingresso
price: uint256

# Endereço do dono do contrato
owner: address

# Número máximo de tickets
limit: uint256
# Número de tickets emitidos
count: uint256

end: bool

# Função que roda quando é feito o deploy do contrato
@external
def __init__(price: uint256, limit: uint256):
    # Guarda o Endereço do dono do contrato na variável
    self.owner = msg.sender
    self.price = price
    self.limit = limit
    self.count = 0
    self.end = False

# Função que encerra o evento
@external
def finish():
    # Testa se é o dono do contrato
    assert msg.sender == self.owner
    
    # Sinaliza e saca o dinheiro do contrato
    self.end = True
    send(msg.sender, self.balance)
    

@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def buy():
    # Testa se o comprador já não comprou
    assert not self.users[msg.sender].valid
    
    # Testa se o valor passado ao contrato foi suficiente
    assert msg.value >= self.price
    
    # Testa se ainda há tickets sobrando
    assert self.count < self.limit
    
    # Testa se o evento ainda não acabou
    assert self.end == False
    
    # Preenche o dicionário com 1 no endereço de quem chamou a função
    # msg.sender existe para toda função e não precisa entrar como argumento
    self.users[msg.sender] =  Passport({
        owner: msg.sender,
        price: self.price,
        valid: True
        })
    
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
    assert self.users[msg.sender].valid
    
    # Testa se o evento ainda não acabou
    assert self.end == False
    
    # Anula a compra
    self.users[msg.sender].valid = False
    # Subtrai 1 do contador de ingressos
    self.count -= 1
    # Devolve 80% do dinheiro (todos os valores tem que ser inteiros)
    send(msg.sender, self.users[msg.sender].price*80/100)
    
# Função que transfere um ingresso
@external
def transfer(destiny: address):
    
    # Testa se o comprador já comprou
    assert self.users[msg.sender].valid
    
    # Testa se o novo comprador não comprou
    assert not self.users[destiny].valid
    
    # Testa se o evento ainda não acabou
    assert self.end == False
    
    # Transfere o ticket para o destino
    self.users[destiny] = self.users[msg.sender]
    # Zera o ticket da origem
    self.users[msg.sender] = empty(Passport)
