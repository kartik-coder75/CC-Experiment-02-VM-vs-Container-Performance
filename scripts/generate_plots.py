import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("results/processed/cpu_results.csv")

for environment in df["environment"].unique():
    data = df[df["environment"] == environment]
    plt.plot(data["threads"], data["events_per_second"], marker="o", label=environment)

plt.xlabel("Number of Threads")
plt.ylabel("Events per Second")
plt.title("CPU Performance vs Number of Threads")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("results/figures/cpu_scalability.png", dpi=300)
plt.show()
