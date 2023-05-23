# Setup private variables (only callable from within the contract)

struct Voter:
    hasVoted: bool
    candidate: address

struct Candidate:
    name: String[64]
    votes: uint256

voters: HashMap[address, Voter]
candidates: HashMap[address, Candidate]

deadline: uint256

# gov's address
gov: address

election_name: String[64]
status: bool

max_votes: uint256
total_votes: uint256

# Setup global variables
@external
def __init__( _time_limit: uint256, _gov: address, election_name: String[64] ):
    self.deadline = block.timestamp + _time_limit
    self.gov = _gov
    self.election_name = election_name
    self.status = True
    self.max_votes = 0
    self.total_votes = 0

@external
def get_candidate_votes(candidate: address) -> uint256:
    return self.candidates[candidate].votes

@external
def add_candidate(candidate: address, name: String[64]):
    assert msg.sender == self.gov, "Only the election authority can add candidates"
    assert self.status == True, "Election is not active"
    assert self.deadline > block.timestamp, "Election has ended, you cant add a candidate"

    self.candidates[candidate] = Candidate({
        name: name,
        votes: 0
    })

@external
def vote(candidate: address):
    assert self.status == True, "Election is not active"
    assert self.deadline > block.timestamp, "Election has ended, this user is not able to vote anymore"
    assert self.voters[msg.sender].hasVoted == False, "You have already voted"

    self.voters[msg.sender] = Voter({
        hasVoted: True,
        candidate: candidate
    })

    self.candidates[candidate].votes += 1
    self.total_votes += 1


