#include <stdio.h>

//cuda headers
#include <cuda.h>
#include <helper-timer.h>

//macros
#define BLOCK_WIDTH 32

//global variables
int *hostA = NULL;
int *hostB = NULL;
int *hostC = NULL;
int *gold = NULL;

int *deviceA = NULL;
int *deviceB = NULL;
int *deviceC = NULL;

float timeOnCPU = 0.0f;
float timeOnGPU = 0.0f;

// cuda kernel function
__global__ void matMulGPU(int *A, int *B, int *C, int numARows, int numAColumns, int numBColumns, int numCColumns)
{
    //variable declarations
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int column = blockIdx.x * blockDim.x + threadIdx.x;

    // code
    if((row < numARows) && (column < numBColumns))
    {
        int value = 0.0;
        
        for(int k = 0; k < numAColumns; k++)
        {
            int a = A[row * numAColumns + k];
            int b = B[k * numBColumns + column];
            value += a * b;
        }

        C[row * numCColumns + column] = value;
    }

}

int main()
{
    // function declarations
    void InitA(int *data,int,int);
    void InitB(int *data,int,int);
    void matmulCPU(int *, int *, int *, int, int, int, int);
    void cleanup(void);

    // variable declaration
    int numARows = BLOCK_WIDTH;
    int numAColumns = BLOCK_WIDTH;
    int numBRows = BLOCK_WIDTH;
    int numBColumns = BLOCK_WIDTH;
    int numCRows = numARows;
    int numCColumns = numBColumns;

    int numGoldRows = numARows;
    int numGodlColumns = numBColumns;

    int sizeA = numARows * numAColumns * sizeof(int);
    int sizeB = numBRows * numBColumns * sizeof(int);
    int sizeC = numCRows * numBColumns * sizeof(int);
    int sizeGold = numGoldRows * numGodlColumns * sizeof(int);

    cudaError_t result = cudaSuccess;

    //code
    //host memory allocation
    hostA = (int*)malloc(sizeA);
    if (hostA == NULL)
    {
        printf("Host Memory allocation is failed for hostA matrix.\n");
        cleanup();
        exit(EXIT_FAILURE);
    }

    hostB = (int*)malloc(sizeB);
    if (hostB == NULL)
    {
        printf("Host Memory allocation is failed for hostB matrix.\n");
        cleanup();
        exit(EXIT_FAILURE);
    }

    hostC = (int*)malloc(sizeC);
    if (hostC == NULL)
    {
        printf("Host Memory allocation is failed for hostC matrix.\n");
        cleanup();
        exit(EXIT_FAILURE);
    }

    gold = (int*)malloc(sizeGold);
    if (gold == NULL)
    {
        printf("Host Memory allocation is failed for gold matrix.\n");
        cleanup();
        exit(EXIT_FAILURE);
    }

    // printing matrix dimensions and sizes
    printf("The Dimensions of Matrix 'hostA' are : %d x %d\n",numARows,numAColumns);
    printf("The Dimensions of Matrix 'hostB' are : %d x %d\n",numBRows,numBColumns);
    printf("The Dimensions of Matrix 'hostC' are : %d x %d\n",numCRows,numCColumns);
    printf("The Dimensions of Matrix 'gold' are : %d x %d\n",numGoldRows,numGodlColumns);

    printf("Size of Matrix hostA = %d\n",sizeA);
    printf("Size of Matrix hostB = %d\n",sizeB);
    printf("Size of Matrix hostC = %d\n",sizeC);
    printf("Size of Matrix gold = %d\n",gold);
}