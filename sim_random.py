import random
class DYRandomizableArray:
    def __init__(self, arr):
        self.array = arr[:]
        self.isRandomized = True
        self.orderedToRandom = list(range(len(arr)))
        self.randomToOrdered = list(range(len(arr)))
    
    def randomize(self):
        count = len(self.array)
        for i in range(count):
            randomIndex = random.randint(i, count - 1)
            # simulate bug:
            self.orderedToRandom[i], self.orderedToRandom[randomIndex] = self.orderedToRandom[randomIndex], self.orderedToRandom[i]
            self.randomToOrdered[i], self.randomToOrdered[randomIndex] = self.randomToOrdered[randomIndex], self.randomToOrdered[i]

    def objectAtIndex(self, index):
        n = self.orderedToRandom[index]
        return self.array[n]
    
    def exchangeObjectAtIndex(self, idx1, idx2):
        self.array[idx1], self.array[idx2] = self.array[idx2], self.array[idx1]
        self.randomToOrdered[idx1], self.randomToOrdered[idx2] = self.randomToOrdered[idx2], self.randomToOrdered[idx1]

arr = DYRandomizableArray(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"])
arr.randomize()

# Let's run the clustering multiple times
for _ in range(5):
    insertPos = 1
    for searchPos in range(1, 10):
        if searchPos != insertPos:
            arr.exchangeObjectAtIndex(insertPos, searchPos)
        insertPos += 1

print([arr.objectAtIndex(i) for i in range(8)])
