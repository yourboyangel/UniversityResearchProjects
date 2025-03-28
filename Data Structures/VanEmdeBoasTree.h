class VanEmdeBoasTree {
public:
    VanEmdeBoasTree(int u);
    int Minimum();
    int Maximum();
    int Successor(int x);
    int Predecessor(int x);
    void Insert(int x);
    void Delete(int x);
    bool Member(int x);
private:
    int u;
    int min;
    int max;
    VanEmdeBoasTree *summary;
    VanEmdeBoasTree **cluster;
    int high(int x);
    int low(int x);
    int index(int x, int y);
};