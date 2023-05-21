# Plataforma de ticket v0.0.2

# Dicionário que indica se o usuário comprou um ticket
# Se retornar 0, o usuário não possui ticket
users: public(HashMap[address, uint256])
# Valor do ingresso
price: uint256

# Função que roda quando é feito o deploy do contrato
@external
def __init__(price: uint256):
    self.price = price

@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def buy():
    # Testa se o valor passado ao contrato foi suficiente
    assert msg.value >= self.price
    
    # Preenche o dicionário com 1 no endereço de quem chamou a função
    # msg.sender existe para toda função e não precisa entrar como argumento
    self.users[msg.sender] = 1
