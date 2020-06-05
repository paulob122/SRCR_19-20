import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.*;

public class Parser {

    public static void main(String[] args) {

        Set<String> paragens = new HashSet<>();

        int i = 0;

        String[] carreiras = {"01", "02", "06", "07",
                "10", "11", "12", "13",
                "15", "23", "101", "102",
                "106", "108", "111", "112",
                "114", "115", "116", "117",
                "119", "122", "125", "129",
                "158", "162", "171", "184",
                "201", "467", "468", "470",
                "471", "479", "714", "748",
                "750", "751", "776"};

        String destParagens = "../paragens.pl";
        String destArcos = "../arcos.pl";

        try {

            BufferedWriter buffWriteParagens = new BufferedWriter(new FileWriter(destParagens));
            BufferedWriter buffWriteArcos = new BufferedWriter(new FileWriter(destArcos));

            while (i < carreiras.length) {

                String pathtoCsv = "../Carreiras/" + carreiras[i] + ".csv";

                BufferedReader csvReader = new BufferedReader(new FileReader(pathtoCsv));

                String row;

                int linha = 0;

                String[] linha_anterior = {""};

                while ((row = csvReader.readLine()) != null) {

                    String[] data = row.split(";");

                    if (linha != 0) {

                        if (!data[1].equals("null") && !data[2].equals("null")) {

                            if (!paragens.contains(data[0])) {
                                buffWriteParagens.write("paragem(" + data[0] + "," + data[1] + ","
                                        + data[2] + ", '" + data[3] + "' , '"
                                        + data[4] + "' , '" + data[5] + "' , '" + data[6] + "').\n");
                                paragens.add(data[0]);
                            }

                            if (linha > 1) {

                                buffWriteArcos.write("arco(" + linha_anterior[0] + "," + data[7] + "," + data[0] + ").\n");
                            }
                        } else {
                            data[1] = "-999999999999999999";
                            data[2] = "-999999999999999999";

                            if (!paragens.contains(data[0])) {
                                buffWriteParagens.write("paragem(" + data[0] + "," + data[1] + ","
                                        + data[2] + ", '" + data[3] + "' , '"
                                        + data[4] + "' , '" + data[5] + "' , '" + data[6] + "').\n");
                                paragens.add(data[0]);
                            }

                            if (linha > 1) {

                                buffWriteArcos.write("arco(" + linha_anterior[0] + "," + data[7] + "," + data[0] + ").\n");
                            }
                        }
                    }
                    linha_anterior = data;
                    linha++;
                }

                i++;

            }

            buffWriteParagens.close();
            buffWriteArcos.close();
        } catch (Exception e) {
            System.out.println(e.toString());
        }

        //System.out.println(arcos.toString());
    }
}
