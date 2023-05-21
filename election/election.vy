# SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2

struct Voter:
    valid: bool
    candidate: address

struct Candidate:
    name: string[64]
    exists: bool
    votes: uint256

struct CandidateOverview:
    name: string[64]
    id: address
    votes: uint256

votes_calculated: bool

candidates_arr: public(CandidateOverview[1000])
owner: address

voters: HashMap(address, Voter)
candidates: HashMap(address, Candidate)

start_time: uint256
end_time: uint256

@public
def __init__(
    _start_time: uint256,
    _end_time: uint256,
    valid_voters: address[1000],
    candidates_addr: address[1000],
    candidates_name: string[1000]
):
    assert len(candidates_addr) == len(candidates_name), "candidates_addr and candidates_name have different sizes"

    for i in range(len(valid_voters)):
        self.voters[valid_voters[i]].valid = True

    for i in range(len(candidates_addr)):
        self.candidates[candidates_addr[i]].name = candidates_name[i]
        self.candidates[candidates_addr[i]].exists = True
        self.candidates_arr[i] = CandidateOverview({
            name: candidates_name[i],
            id: candidates_addr[i],
            votes: 0
        })

    self.owner = msg.sender
    self.start_time = _start_time
    self.end_time = _end_time

@public
@constant
def hasVoted(voter: address) -> bool:
    assert msg.sender == self.owner, "Only election owner can search for who has voted."
    assert block.timestamp > self.end_time, "You can only see who hasn't voted after the election."

    return self.voters[voter].candidate != ZERO_ADDRESS

@public
@constant
def getCandidates() -> CandidateOverview[1000]:
    return self.candidates_arr

@public
def castVote(candidate: address):
    assert block.timestamp >= self.start_time and block.timestamp <= self.end_time, "Cannot cast vote at this time."
    assert self.voters[msg.sender].candidate == ZERO_ADDRESS, "You already voted."
    assert self.voters[msg.sender].valid, "You are not a valid voter."
    assert self.candidates[candidate].exists, "This candidate does not exist in this election."

    self.candidates[candidate].votes += 1
    self.voters[msg.sender].candidate = candidate

@public
@constant
def getVote() -> address:
    return self.voters[msg.sender].candidate

@public
@constant
def getCandidateVotes(candidate: address) -> uint256:
    assert block.timestamp > self.end_time, "Cannot get votes before end of election."
    return self.candidates[candidate].votes

@public
def calculateCandidatesVotes():
    assert block.timestamp > self.end_time, "Cannot get votes before end of election."
    if self.votes_calculated:
        return

    for i in range(len(self.candidates_arr)):
        self.candidates_arr[i].votes = self.candidates[self.candidates_arr[i].id].votes

    self.votes_calculated = True
