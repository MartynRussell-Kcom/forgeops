/*
 * Copyright 2019-2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

void runStage(pipelineRun) {
    def parallelTestsMap = [
        Greenfield: { greenfieldTests.runStage(pipelineRun) },
        //Upgrade: { upgradeTests.runStage(pipelineRun) },
        PerfPit2: { perfTests.runStage(pipelineRun, 'PERF-PIT2', 'jenkins.yaml', "True", "pyrock") }
    ]

    parallel parallelTestsMap
}

return this
