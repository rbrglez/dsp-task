import numpy as np

# Get matrix dimensions
M = 32
N = 32

# Input matrix
matrix = []
for i in range(M):
    row = []
    for j in range(N):
        row.append(j + i*N);
    matrix.append(row)

vector = []
for i in range(N):
    vector.append(i);

# Convert to numpy arrays
A = np.array(matrix)
v = np.array(vector)

# Compute matrix-vector product
result = np.dot(A, v)

# Display result
print("\nMatrix A:")
print(A)
print("\nVector v:")
print(v)
print("\nMatrix-Vector Product (A·v):")
print(result)

print()
print()
for i in range(M):
    print(f"{i} = {result[i]}")
