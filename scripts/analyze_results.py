import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv(
 "results/processed/cpu_results.csv"
)
print(df)
summary = df.groupby("environment")[
 "events_per_second"
].mean()
print("\nAverage CPU Performance:")
print(summary)
summary.plot(
 kind="bar",
 title="Average CPU Performance"
)
plt.ylabel("Events per Second")
plt.xlabel("Environment")
plt.tight_layout()
plt.savefig(
 "results/figures/cpu_performance.png",
 dpi=300
)
plt.show()
