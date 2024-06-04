import FWCore.ParameterSet.Config as cms

# load common code
from Configuration.StandardSequences.Eras import eras
process = cms.Process('directsim', eras.Run3)

# load config
# 2021 -> 2022
import Validation.CTPPS.simu_config.year_2022_cff as config
process.load("Validation.CTPPS.simu_config.year_2022_cff")
process.ctppsCompositeESSource.periods=[config.profile_2022_default]

process.load('Configuration.EventContent.EventContent_cff')

# minimal logger settings                                                                                                           
process.load("FWCore.MessageService.MessageLogger_cfi")
process.options   = cms.untracked.PSet(
    allowUnscheduled = cms.untracked.bool(True),
)

# event source         
process.source = cms.Source("PoolSource",
  fileNames = cms.untracked.vstring('file:xinput'))

# number of events
process.maxEvents = cms.untracked.PSet(
input = cms.untracked.int32(-1)
)

# update settings of beam-smearing module
process.beamDivergenceVtxGenerator.src = cms.InputTag("")
process.beamDivergenceVtxGenerator.srcGenParticle = cms.VInputTag(
#    cms.InputTag("genPUProtons","genPUProtons"),
    cms.InputTag("genParticles")
)

# do not apply vertex smearing again
process.ctppsBeamParametersFromLHCInfoESSource.vtxStddevX = 0
process.ctppsBeamParametersFromLHCInfoESSource.vtxStddevY = 0
process.ctppsBeamParametersFromLHCInfoESSource.vtxStddevZ = 0

# undo CMS vertex shift
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetX45 = 0. 
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetY45 = 0.
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetZ45 = 0.
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetX56 = 0.
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetY56 = 0.
process.ctppsBeamParametersFromLHCInfoESSource.vtxOffsetZ56 = 0.

process.out = cms.OutputModule('PoolOutputModule',
    fileName = cms.untracked.string('xfileout'),
    outputCommands = process.AODSIMEventContent.outputCommands,
    splitLevel = cms.untracked.int32(0)
)

process.out.outputCommands.append('keep *_*_*_*')

# processing path
process.p = cms.Path(
  process.beamDivergenceVtxGenerator
  * process.ctppsDirectProtonSimulation
  * process.reco_local
  * process.ctppsProtons
)

process.outpath = cms.EndPath(process.out)

process.schedule = cms.Schedule(
    process.p,
    process.outpath
)
