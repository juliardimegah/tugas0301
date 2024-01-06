<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "ulbi2024db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Gagal menghubungkan: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {

    $sql = "SELECT * FROM mstmmatkul";
    $result = $conn->query($sql);
    $products = array();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
    }
    echo json_encode($products);
} elseif ($_SERVER["REQUEST_METHOD"] === "POST") {
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data["kode_matkul"]) && isset($data["nama_matkul"]) && isset($data["dosen"])) {
        $kodeMatkul = $data["kode_matkul"];
        $namaMatkul = $data["nama_matkul"];
        $dosen = $data["dosen"];

        $sql = "INSERT INTO mstmmatkul (kode_matkul, nama_matkul, dosen) VALUES ('$kodeMatkul', '$namaMatkul', '$dosen')";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Isi data berhasil disimpan"));
        } else {
            echo json_encode(array("message" => "Error: " . $sql . "<br>" . $conn->error));
        }
    } else {
        echo json_encode(array("message" => "Error: Incomplete data sent in the request."));
    }
} elseif ($_SERVER["REQUEST_METHOD"] === "PUT") { // Add the PUT method
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data["kode_matkul"]) && isset($data["nama_matkul"]) && isset($data["dosen"])) {
        $kodeMatkul = $data["kode_matkul"];
        $namaMatkul = $data["nama_matkul"];
        $dosen = $data["dosen"];

        $sql = "UPDATE mstmmatkul SET nama_matkul = '$namaMatkul', dosen = '$dosen' WHERE kode_matkul = '$kodeMatkul'";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Data berhasil diperbarui"));
        } else {
            echo json_encode(array("message" => "Error: " . $sql . "<br>" . $conn->error));
        }
    } else {
        echo json_encode(array("message" => "Error: Incomplete data sent in the request."));
    }
} elseif ($_SERVER["REQUEST_METHOD"] === "DELETE") {
    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data["kode_matkul"])) {
        $kodeMatkul = $data["kode_matkul"];
        $sql = "DELETE FROM mstmmatkul WHERE kode_matkul = '$kodeMatkul'";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Data berhasil dihapus"));
        } else {
            echo json_encode(array("message" => "Error: " . $sql . "<br>" . $conn->error));
        }
    } else {
        echo json_encode(array("message" => "Error: Incomplete data sent in the request."));
    }
}

$conn->close();
?>