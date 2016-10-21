<?php

namespace biomcs;

require_once __DIR__.'/../overload_header_function.php';

class BiomCSTest extends \PHPUnit_Framework_TestCase
{
    public function testConvertToJSON()
    {
        $biomcs = new BiomCS();
        // Test for conversion of biom content in HDF5 format
        $results = $biomcs->convertToJSON(file_get_contents(__DIR__ . '/../files/simpleBiom.hdf5'));
        $results_obj = json_decode($results, true);
        // var_dump($results_obj);
        $this->assertEquals("b'No Table ID'", $results_obj["id"]);
        $this->assertEquals("Biological Observation Matrix 1.0.0", $results_obj["format"]);
        $this->assertEquals(array(3,1,12), $results_obj["data"][1]);
        $this->assertEquals("OTU_8", $results_obj["rows"][7]["id"]);
        $this->assertEquals("Sample_3", $results_obj["columns"][2]["id"]);
    }

    public function testConvertToHDF5()
    {
        $biomcs = new BiomCS();
        // Test for conversion of biom content in json format
        // Only the file format HDF5 is checked by inspecting the first four bytes
        // this is by no means a sufficient but only a necessary condition for correctness
        $results = $biomcs->convertToHDF5(file_get_contents(__DIR__ . '/../files/simpleBiom.json'));
        // var_dump($results_obj);
        $this->assertEquals(137, ord(substr($results, 0, 1)));
        $this->assertEquals("HDF", substr($results, 1, 3));
    }

    public function testEmptyStringException()
    {
        $biomcs = new BiomCS();
        // Test for conversion of an empty string (Should raise an exception)
        $this->expectException(\Exception::class);
        $results = $biomcs->convertToHDF5("");
    }
}
