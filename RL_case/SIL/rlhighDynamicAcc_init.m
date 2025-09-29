% 高机动控制仿真和实飞的参数略有差别
% 因为高机动运动时仿真模型与实飞模型的差异会在高度机动控制中被放大
close all
clear

% 运行步长，频率的倒数
fixed_step_size = 1/50;

% PID参数
Pos_Y_P=1.0;
Pos_Y_I=0.0;
Pos_Z_P=1.0;
Yaw_P=1.0;
Yaw_I=0.1;
Saturation_I_ah=1.0;
MAX_YAW_RATE=1.0;
% 仿真场景
MAX_POS_ERR = 4.0;

MAX_ACC_HOR = 4.0;
Vel_Y_P=2.0;
Vel_Y_I=0.5;

Ts = fixed_step_size;
Tf = 200;

obsInfo = rlNumericSpec([6 1],...
    LowerLimit=[-100 -5 -10 -10 -100 -10]',...
    UpperLimit=[ 100  5 10 10 100 10]');
obsInfo.Name = "observations";
obsInfo.Description = "integrated error, error, measured x, measured v, integrated v, derivative v";

actInfo = rlNumericSpec([1 1], 'LowerLimit', -4, 'UpperLimit', 4);
actInfo.Name = "accx";

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

agent.AgentOptions.NoiseOptions.Variance = 0.3;
agent.AgentOptions.NoiseOptions.VarianceDecayRate = 1e-5;

agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-03;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;
agent.AgentOptions.ActorOptimizerOptions.LearnRate = 1e-04;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold = 1;

getAction(agent,{rand(obsInfo.Dimension)})

% Load the pretrained agent for the example.
load("UAVDPPG.mat","agent");
