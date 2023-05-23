# Setup private variables (only callable from within the contract)

struct Voter:
    hasVoted: bool
    candidate: address

struct Candidate:
    name: String[64]
    votes: uint256

voters: HashMap[address, Voter]
candidates: HashMap[address, Candidate]

start_time: uint256
end_time: uint256

# gov's address
gov: address

election_name: String[64]
status: bool

winner: address
max_votes: uint256
total_votes: uint256

# Setup global variables
@external
def __init__( _start_time: uint256, _end_time: uint256, gov: address, election_name: String[64] ):
    self.start_time = _start_time
    self.end_time = _end_time
    self.gov = gov
    self.election_name = election_name
    self.status = True
    self.winner = ZERO_ADDRESS
    self.max_votes = 0
    self.total_votes = 0

@external
def get_candidate_votes(candidate: address) -> uint256:
    return self.candidates[candidate].votes

# @external
# def get_num_of_candidates() -> uint256:
#     return len(self.candidates)

# @external
# def get_num_of_voters() -> uint256:
#     return len(self.voters)

@external
def add_candidate(candidate: address, name: String[64]):
    assert msg.sender == self.gov, "Only the election authority can add candidates"
    assert self.status == True, "Election is not active"

    self.candidates[candidate] = Candidate({
        name: name,
        votes: 0
    })


@external
def vote(candidate: address):
    assert self.status == True, "Election is not active"
    assert self.start_time <= block.timestamp, "Election has not started yet"
    assert self.end_time >= block.timestamp, "Election has ended"
    assert self.voters[msg.sender].hasVoted == False, "You have already voted"

    self.voters[msg.sender] = Voter({
        hasVoted: True,
        candidate: candidate
    })

    self.candidates[candidate].votes += 1
    self.total_votes += 1

@external
def count_votes() -> address:
    assert self.status == True, "Election is still active"
    assert self.end_time <= block.timestamp, "Election has not ended yet"
    assert self.start_time <= block.timestamp, "Election has not started yet"
    assert self.gov == msg.sender, "Only the election authority can count votes"

    self.status = False

    self.max_votes = 0

    for index in range(self.total_votes):
        if self.candidates[index].votes > self.max_votes:
            self.winner = index
            self.max_votes = self.candidates[index].votes

    return self.candidates[self.winner]
