import FWCore.ParameterSet.Config as cms

from Configuration.StandardSequences.Eras import eras
process = cms.Process('RECO',eras.Run3)

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load("Configuration.EventContent.EventContent_cff")
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')
process.load('Configuration.StandardSequences.RawToDigi_cff')
process.load('Configuration.StandardSequences.Reconstruction_cff')
process.load('Configuration.StandardSequences.GeometryDB_cff')
#process.load("Geometry.VeryForwardGeometry.geometryRPFromDB_cfi")
#process.load("Geometry.VeryForwardGeometry.geometryPPS_CMSxz_fromDD_2018_cfi") # CMS frame, 2021 = 2018

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(-1)
)

# Input source
process.source = cms.Source("PoolSource",
    fileNames = cms.untracked.vstring('file:xinput'),
    duplicateCheckMode = cms.untracked.string('noDuplicateCheck'),
    secondaryFileNames = cms.untracked.vstring()
)

# Track memory leaks
process.SimpleMemoryCheck = cms.Service("SimpleMemoryCheck",ignoreTotal = cms.untracked.int32(1) )
process.options = cms.untracked.PSet(
    SkipEvent = cms.untracked.vstring('ProductNotFound')
)

# Output definition

process.output = cms.OutputModule("PoolOutputModule",
    compressionAlgorithm = cms.untracked.string('LZMA'),
    compressionLevel = cms.untracked.int32(4),
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('AODSIM'),
        filterName = cms.untracked.string('')
    ),
    fileName = cms.untracked.string('xfileout'),
    outputCommands = cms.untracked.vstring(
        "drop *",
        "keep SimVertexs_g4SimHits_*_*",
        "keep PSimHits*_*_*_*",
        "keep CTPPS*_*_*_*",
        "keep *_*RP*_*_*",
        "keep *_generatorSmeared_*_*",
        "keep *_generator_unsmeared_*",
        "keep *_beamDivergenceVtxGenerator_*_*",
        "keep recoForwardProtons_ctppsProtons_*_*")
    #outputCommands = cms.untracked.vstring("keep *")
)

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'auto:phase1_2022_realistic', '')

# Path and EndPath definitions
process.raw2digi_step = cms.Path(process.RawToDigi)
process.reco_step = cms.Path(process.reconstruction)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.output_step = cms.EndPath(process.output)

# Schedule definition
process.schedule = cms.Schedule(process.raw2digi_step,process.reco_step,process.endjob_step,process.output_step)

# filter all path with the production filter sequence
for path in process.paths:
    #  getattr(process,path)._seq = process.ProductionFilterSequence * getattr(process,path)._seq
    getattr(process,path)._seq = getattr(process,path)._seq
