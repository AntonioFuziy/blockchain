price: uint256
users: public(HashMap[address, uint256])
payment: HashMap[address, uint256]
owner: address
limit: uint256
cont: uint256

@external
def __init__(price: uint256):
    self.price = price
    self.owner = msg.sender
    self.limit = limit
    self.cont = 0

#funcao de compra
@external #pode ser executado por todos
@payable #permite receber dinheiro
def buy():
    #checa se o preco passado eh o valor do ingresso ou maior
    assert msg.value >= self.price
    #checa o limite de transacoes
    assert self.limit < self.cont
    #nao se compra duas vezes
    assert self.users[msg.sender] == 0
    self.users[msg.sender] = 1
    self.payment[msg.sender] = self.price
    self.cont += 1

@external
def change_price(new_price: uint256):
    assert msg.sender == self.owner
    self.price = new_price

@external 
def cancel():
    assert self.users[msg.sender] == 1
    self.users[msg.sender] = 0
    self.count -= 1
    send(msg.sender, self.payment[msg.sender]*80/100)

@external
def transfer(destiny: address)
    assert self.users[msg.sender] == 1
    assert self.users[destiny] == 0
    self.users[msg.sender] = 0
    self.users[destiny] = 1

    self.payment[destiny] = self.payment[msg.sender]
