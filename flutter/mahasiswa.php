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

    $sql = "SELECT * FROM mstmahasiswa";
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

    if (isset($data["npm"]) && isset($data["nama_lengkap"]) && isset($data["alamat"])) {
        $npm = $data["npm"];
        $namaLengkap = $data["nama_lengkap"];
        $alamat = $data["alamat"];

        $sql = "INSERT INTO mstmahasiswa (npm, nama_lengkap, alamat) VALUES ('$npm', '$namaLengkap', '$alamat')";
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

    if (isset($data["npm"]) && isset($data["nama_lengkap"]) && isset($data["alamat"])) {
        $npm = $data["npm"];
        $namaLengkap = $data["nama_lengkap"];
        $alamat = $data["alamat"];

        $sql = "UPDATE mstmahasiswa SET nama_lengkap = '$namaLengkap', alamat = '$alamat' WHERE npm = '$npm'";
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

    if (isset($data["npm"])) {
        $npm = $data["npm"];
        $sql = "DELETE FROM mstmahasiswa WHERE npm = '$npm'";

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