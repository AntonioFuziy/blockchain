# @version ^0.2.0

owner: address
target: public(uint256)
endtime: public(uint256)

donations: public(HashMap[address, uint256])

@external
def __init__(target: uint256, endtime: uint256):

    assert endtime >= block.timestamp

    self.owner = msg.sender

    self.target = target
    self.endtime = endtime

@external
@payable
def fund():

    assert self.endtime >= block.timestamp

    self.donations[msg.sender] += msg.value

@external
def finish():

    assert msg.sender == self.owner

    assert self.balance >= self.target

    assert self.endtime <= block.timestamp

    selfdestruct(self.owner)

@external
def refund():

    assert self.endtime <= block.timestamp

    assert self.balance < self.target

    assert self.donations[msg.sender] > 0

    send(msg.sender, self.donations[msg.sender])

    self.donations[msg.sender] = 0

