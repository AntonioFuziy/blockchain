# Plataforma de ticket v0.0.1

# Dicionário que indica se o usuário comprou um ticket
# Se retornar 0, o usuário não possui ticket
users: public(HashMap[address, uint256])

@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def buy():

    # Preenche o dicionário com 1 no endereço de quem chamou a função
    # msg.sender existe para toda função e não precisa entrar como argumento
    self.users[msg.sender] = 1
