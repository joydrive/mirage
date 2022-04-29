defmodule Mirage.ImageTest do
  use ExUnit.Case, async: true

  doctest Mirage.Image

  @test_image_path "./test/support/images/scrogson.jpeg"
  @invalid_image_path "./test/support/images/not_an_image.txt"
  @nonexistant_image_path "does-not-exist.txt"

  describe "from_bytes/1" do
    test "returns a tuple containing an image and the discovered format from the provided bytes" do
      bytes = File.read!(@test_image_path)

      {:ok, :jpeg, image} = Mirage.Image.from_bytes(bytes)

      assert image.byte_size == 634_800
      assert image.width == 460
      assert image.height == 460
      assert is_reference(image.resource)
    end

    test "fails when the provided bytes are not an image" do
      failing_bytes = <<123, 213, 231>>

      {:error, :invalid_image} = Mirage.Image.from_bytes(failing_bytes)
    end
  end

  describe "read/1" do
    test "returns a tuple containing an image and the discovered format for a given filepath" do
      {:ok, :jpeg, image} = Mirage.Image.read(@test_image_path)

      assert image.byte_size == 634_800
      assert image.width == 460
      assert image.height == 460
      assert is_reference(image.resource)
    end

    test "fails when the provided path does not exist" do
      {:error, :enoent} = Mirage.Image.read(@nonexistant_image_path)
    end

    test "fails when the provided path is not an image" do
      {:error, :invalid_image} = Mirage.Image.read(@invalid_image_path)
    end
  end

  describe "read!/1" do
    test "returns a tuple containing an image and the discovered format for a given filepath" do
      {:jpeg, image} = Mirage.Image.read!(@test_image_path)

      assert image.byte_size == 634_800
      assert image.width == 460
      assert image.height == 460
      assert is_reference(image.resource)
    end

    test "raises when the provided path does not exist" do
      exception =
        assert_raise Mirage.ReadError, fn ->
          Mirage.Image.read!(@nonexistant_image_path)
        end

      assert exception.path == @nonexistant_image_path
      assert exception.error == :enoent

      assert exception.message ==
               "Error while reading image from path '#{@nonexistant_image_path}': ':enoent'"
    end

    test "raises when the provided path is not an image" do
      exception =
        assert_raise Mirage.ReadError, fn ->
          Mirage.Image.read!(@invalid_image_path)
        end

      assert exception.path == @invalid_image_path
      assert exception.error == :invalid_image

      assert exception.message ==
               "Error while reading image from path '#{@invalid_image_path}': ':invalid_image'"
    end
  end

  describe "write/1" do
    test "returns :ok when the image is written successfully" do
      tmp_image_path = "./test/support/images/test_output_image1.png"

      {:jpeg, image} = Mirage.Image.read!(@test_image_path)

      assert :ok == Mirage.Image.write(image, tmp_image_path)

      # If the image can be read back at this point, then the image was written
      # successfully.
      Mirage.Image.read!(@test_image_path)

      File.rm(tmp_image_path)
    end
  end

  describe "write!/1" do
    test "returns :ok when the image is written successfully" do
      tmp_image_path = "./test/support/images/test_output_image2.png"

      {:jpeg, image} = Mirage.Image.read!(@test_image_path)

      assert :ok == Mirage.Image.write!(image, tmp_image_path)

      # If the image can be read back at this point, then the image was written
      # successfully.
      Mirage.Image.read!(@test_image_path)

      File.rm(tmp_image_path)
    end
  end

  test "empty/2" do
    image = Mirage.Image.empty(100, 100)

    :ok = Mirage.Image.write(image, "./test/support/images/empty.png")
  end
end
