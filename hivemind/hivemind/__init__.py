from hivemind.averaging import DecentralizedAverager
from hivemind.compression import (
    CompressionBase,
    Float16Compression,
    NoCompression,
    ScaledFloat16Compression,
)
from hivemind.dht import DHT
from hivemind.utils import (
    DHTExpiration,
    MPFuture,
    ValueWithExpiration,
    get_dht_time,
    get_logger,
)
from hivemind.moe import (
    ModuleBackend,
    RemoteExpert,
    RemoteMixtureOfExperts,
    RemoteSwitchMixtureOfExperts,
    Server,
    register_expert_class,
)
from hivemind.optim import GradScaler, Optimizer, TrainingAverager

__version__ = "1.2.0.dev0"
