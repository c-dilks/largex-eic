// SPDX-License-Identifier: LGPL-3.0-or-later
// Copyright (C) 2022 Sanghwa Park, Christopher Dilks

#ifndef AnalysisAthena_
#define AnalysisAthena_

#include "TTreeReader.h"
#include "TTreeReaderValue.h"
#include "TTreeReaderArray.h"

#include "Analysis.h"

class AnalysisAthena : public Analysis
{
  public:
    AnalysisAthena(TString configFileName_="", TString outfilePrefix_="");
    ~AnalysisAthena();

    void Execute() override;

    ClassDefOverride(AnalysisAthena,1);
};

#endif
