import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

public class Aoc9 {
    public static void main(String[] args){
        Scanner scan = new Scanner(System.in).useDelimiter("\n");
        int accum = 0;
        while (scan.hasNext()) {
            String history = scan.next();
            accum += solve2(history);
        }
        System.out.println(accum);
    }

    private static int solve1(String history) {
        int[] input = Arrays.stream(history.split(" "))
                .mapToInt(Integer::parseInt)
                .toArray();

        ArrayList<int[]> historyTiers = new ArrayList<>();
        historyTiers.add(input);

        int[] current = input;
        while(!isAllZero(current)){
            System.out.println(Arrays.toString(current));
            current = diff(current);
            historyTiers.add(current);
        }

        int nextValue = 0;
        for (int i = historyTiers.size() - 2; i >= 0; i--) {
            int[] currentTier = historyTiers.get(i);
            int lastValue = currentTier[currentTier.length - 1];
            nextValue = lastValue + nextValue;
        }

        return nextValue;
    }

    private static int solve2(String history) {
        int[] input = Arrays.stream(history.split(" "))
                .mapToInt(Integer::parseInt)
                .toArray();

        ArrayList<int[]> historyTiers = new ArrayList<>();
        historyTiers.add(input);

        int[] current = input;
        while(!isAllZero(current)){
            current = diff(current);
            historyTiers.add(current);
        }

        int nextValue = 0;
        for (int i = historyTiers.size() - 2; i >= 0; i--) {
            int[] currentTier = historyTiers.get(i);
            int firstValue = currentTier[0];
            // lastNextValue = firstValue - nextValue
            // -nextValue = lastNextValue - firstValue
            // nextValue = firstValue - lastNextValue
            System.out.printf("Tier %d, %d - %d\n", i, firstValue, nextValue);
            nextValue = firstValue - nextValue;
        }
        System.out.printf("Input: %s, out = %d\n", Arrays.toString(input), nextValue);

        return nextValue;
    }

    private static int[] diff(int[] input) {
        int[] out = new int[input.length - 1];
        for(int i = 1; i < input.length; i++){
            out[i-1] = input[i] - input[i-1];
        }
        return out;
    }

    private static boolean isAllZero(int[] input) {
        return Arrays.stream(input).allMatch(i -> i == 0);
    }
}
