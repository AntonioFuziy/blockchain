struct Owner:
    addr: address
    amount: uint256

struct Beneficiary:
    addr: address
    amount: uint256

# Setup private variables (only callable from within the contract)

funders: HashMap[address, uint256]
deadline: public(uint256)
goal: public(uint256)
timelimit: public(uint256)
beneficiary: Beneficiary
owner: Owner

# Setup global variables
@external
def __init__(_beneficiary: address, _goal: uint256, _timelimit: uint256, _owner: address):
    self.beneficiary.addr = _beneficiary
    self.beneficiary.amount = 0
    self.deadline = block.timestamp + _timelimit
    self.timelimit = _timelimit
    self.goal = _goal
    self.owner.addr = _owner
    self.owner.amount = 0

# Participate in this crowdfunding campaign
@external
@payable
def participate():
    assert block.timestamp < self.deadline, "deadline  error"

    self.funders[msg.sender] += msg.value

# Enough money was raised! Send funds to the beneficiary
@external
def finalize():
    assert block.timestamp >= self.deadline, "deadline  error"

    if self.balance >= self.goal:
        self.owner.amount = self.goal * 1/10
        self.beneficiary.amount = self.goal - self.owner.amount
        send(self.beneficiary.addr, self.beneficiary.amount)
    else:   
        self.owner.amount = self.balance * 1/10

    send(self.owner.addr, self.owner.amount)
    selfdestruct(self.beneficiary.addr)

# Let participants withdraw their fund

@external
def refund():
    assert block.timestamp >= self.deadline and self.balance < self.goal, "not able to change deadline"
    assert self.funders[msg.sender] > 0

    value: uint256 = self.funders[msg.sender]
    self.funders[msg.sender] = 0

    send(msg.sender, value * 9/10)

@external
def change_goal(new_goal: uint256):
    assert msg.sender == self.owner.addr, "this user is not able to change goal"
    self.goal = new_goal

@external
def change_deadline(new_deadline: uint256):
    assert msg.sender == self.owner.addr, "this user is not able to change deadline"
    assert block.timestamp < new_deadline, "timestamp error"
    self.deadline = new_deadline
