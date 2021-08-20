#include "SimpleTree.h"

ClassImp(SimpleTree)

// constructor
SimpleTree::SimpleTree(TString treeName_, Kinematics *K_) 
  : treeName(treeName_)
  , K(K_)
{
  // branch names are set to match `brufit` implementation
  // (see `https://github.com/c-dilks/dispin/tree/master/src`)
  T = new TTree(treeName,treeName);
  T->Branch("Q2",        &(K->Q2),     "Q2/D");
  T->Branch("X",         &(K->x),      "X/D");
  T->Branch("Z",         &(K->z),      "Z/D");
  T->Branch("PhPerp",    &(K->pT),     "PhPerp/D");
  T->Branch("PhiH",      &(K->phiH),   "PhiH/D");
  T->Branch("PhiS",      &(K->phiS),   "PhiS/D");
  T->Branch("Pol",       &(K->pol),    "Pol/D");
  T->Branch("Spin_idx",  &(K->tSpin),  "Spin_idx/I");
  T->Branch("Weight",    &(weight),    "Weight/D");
};

// destructor
SimpleTree::~SimpleTree() {
};

