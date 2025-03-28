#include "VanEmdeBoasTree.h"
#include "math.h"

VanEmdeBoasTree::VanEmdeBoasTree(int u) {
    this->u = u;
    min = -1;
    max = -1;
    if (u > 2) {
        int size = (int) ceil(sqrt(u));
        summary = new VanEmdeBoasTree(size);
        cluster = new VanEmdeBoasTree*[size];
        for (int i = 0; i < size; i++) {
            cluster[i] = new VanEmdeBoasTree(size);
        }
    }
}

int VanEmdeBoasTree::Minimum() {
    return min;
}

int VanEmdeBoasTree::Maximum() {
    return max;
}

int VanEmdeBoasTree::Successor(int x) {
    if (u == 2) {
        if (x == 0 && max == 1) {
            return 1;
        } else {
            return -1;
        }
    } else if (min != -1 && x < min) {
        return min;
    } else {
        int maxLow = cluster[high(x)]->Maximum();
        if (maxLow != -1 && low(x) < maxLow) {
            int offset = cluster[high(x)]->Successor(low(x));
            return index(high(x), offset);
        } else {
            int succCluster = summary->Successor(high(x));
            if (succCluster == -1) {
                return -1;
            } else {
                int offset = cluster[succCluster]->Minimum();
                return index(succCluster, offset);
            }
        }
    }
}

int VanEmdeBoasTree::Predecessor(int x) {
    if (u == 2) {
        if (x == 1 && min == 0) {
            return 0;
        } else {
            return -1;
        }
    } else if (max != -1 && x > max) {
        return max;
    } else {
        int minLow = cluster[high(x)]->Minimum();
        if (minLow != -1 && low(x) > minLow) {
            int offset = cluster[high(x)]->Predecessor(low(x));
            return index(high(x), offset);
        } else {
            int predCluster = summary->Predecessor(high(x));
            if (predCluster == -1) {
                if (min != -1 && x > min) {
                    return min;
                } else {
                    return -1;
                }
            } else {
                int offset = cluster[predCluster]->Maximum();
                return index(predCluster, offset);
            }
        }
    }
}

bool VanEmdeBoasTree::Member(int x) {
    if (x == min || x == max) {
        return true;
    } else if (u == 2) {
        return false;
    } else {
        return cluster[high(x)]->Member(low(x));
    }
}

void VanEmdeBoasTree::Insert(int x) {
    if (min == -1) {
        min = max = x;
    } else {
        if (x < min) {
            int temp = min;
            min = x;
            x = temp;
        }
        if (u > 2) {
            if (cluster[high(x)]->Minimum() == -1) {
                summary->Insert(high(x));
                cluster[high(x)]->min = low(x);
                cluster[high(x)]->max = low(x);
            } else {
                cluster[high(x)]->Insert(low(x));
            }
        }
        if (x > max) {
            max = x;
        }
    }
}

void VanEmdeBoasTree::Delete(int x) {
    if (min == max) {
        min = max = -1;
    } else if (u == 2) {
        if (x == 0) {
            min = 1;
        } else {
            min = 0;
        }
        max = min;
    } else {
        if (x == min) {
            int firstCluster = summary->Minimum();
            x = index(firstCluster, cluster[firstCluster]->Minimum());
            min = x;
        }
        cluster[high(x)]->Delete(low(x));
        if (cluster[high(x)]->Minimum() == -1) {
            summary->Delete(high(x));
            if (x == max) {
                int summaryMax = summary->Maximum();
                if (summaryMax == -1) {
                    max = min;
                } else {
                    max = index(summaryMax, cluster[summaryMax]->Maximum());
                }
            }
        } else if (x == max) {
            max = index(high(x), cluster[high(x)]->Maximum());
        }
    }
}

int VanEmdeBoasTree::high(int x) {
    return (int) floor(x / sqrt(u));
}

int VanEmdeBoasTree::low(int x) {
    return x % (int) ceil(sqrt(u));
}

int VanEmdeBoasTree::index(int x, int y) {
    return x * (int) ceil(sqrt(u)) + y;
}