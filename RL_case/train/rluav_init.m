Ts = 1/50.0;
Tf = 20;

obsInfo = rlNumericSpec([6 1],...
    LowerLimit=[-100 -5 -10 -10 -100 -10]',...
    UpperLimit=[ 100  5 10 10 100 10]');
obsInfo.Name = "observations";
obsInfo.Description = "integrated error, error, measured x, measured v, integrated v, derivative v";
actInfo = rlNumericSpec([1 1], 'LowerLimit', -4, 'UpperLimit', 4);
actInfo.Name = "accx";
env = rlSimulinkEnv("rluav","rluav/RL Agent",...
    obsInfo,actInfo);
env.ResetFcn = @(in)rluavlocalResetFcn(in);

rng(0);
statePath = [
    featureInputLayer(obsInfo.Dimension(1),Name="netObsIn")
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(25,Name="CriticStateFC2")];

actionPath = [
    featureInputLayer(actInfo.Dimension(1),Name="netActIn")
    fullyConnectedLayer(25,Name="CriticActionFC1")];

commonPath = [
    additionLayer(2,Name="add")
    reluLayer
    fullyConnectedLayer(1,Name="CriticOutput")];

criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);

criticNetwork = connectLayers(criticNetwork, ...
    "CriticStateFC2", ...
    "add/in1");
criticNetwork = connectLayers(criticNetwork, ...
    "CriticActionFC1", ...
    "add/in2");
criticNetwork = dlnetwork(criticNetwork);
summary(criticNetwork)
critic = rlQValueFunction(criticNetwork,obsInfo,actInfo, ...
    ObservationInputNames="netObsIn", ...
    ActionInputNames="netActIn");
getValue(critic, ...
    {rand(obsInfo.Dimension)}, ...
    {rand(actInfo.Dimension)})
actorNetwork = [
    featureInputLayer(obsInfo.Dimension(1))
    fullyConnectedLayer(3)
    tanhLayer
    fullyConnectedLayer(actInfo.Dimension(1))
    ];
actorNetwork = dlnetwork(actorNetwork);
summary(actorNetwork)
actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo);
agent = rlDDPGAgent(actor,critic);

agent.SampleTime = Ts;

agent.AgentOptions.TargetSmoothFactor = 1e-3;
agent.AgentOptions.DiscountFactor = 1.0;
agent.AgentOptions.MiniBatchSize = 64;
agent.AgentOptions.ExperienceBufferLength = 1e6; 

agent.AgentOptions.NoiseOptions.Variance = 0.1;
agent.AgentOptions.NoiseOptions.VarianceDecayRate = 1e-5;

agent.AgentOptions.CriticOptimizerOptions.LearnRate = 5e-04;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;
agent.AgentOptions.ActorOptimizerOptions.LearnRate = 5e-05;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold = 1;

getAction(agent,{rand(obsInfo.Dimension)})

trainOpts = rlTrainingOptions(...
    MaxEpisodes=5000, ...
    MaxStepsPerEpisode=ceil(Tf/Ts), ...
    ScoreAveragingWindowLength=20, ...
    Verbose=false, ...
    Plots="training-progress",...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=1000);
trainOpts.SaveAgentCriteria = "EpisodeReward";
trainOpts.SaveAgentValue = 1000;
doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
    save("UAVDPPG.mat",'agent');
else
    % Load the pretrained agent for the example.
    load("UAVDPPG.mat","agent");
end

simOpts = rlSimulationOptions(MaxSteps=ceil(Tf/Ts),StopOnError="on");
experiences = sim(env,agent,simOpts);