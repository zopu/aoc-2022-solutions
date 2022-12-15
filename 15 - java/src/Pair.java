public class Pair<T> {
    public T x;
    public T y;
    Pair(T x, T y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public String toString() {
        return "(" + this.x.toString() + "," + this.y.toString() + ")";
    }
}
