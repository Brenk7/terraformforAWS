data "aws_availability_zones" "available" {}

resource "aws_vpc" "istio" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "terraform-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "istio" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.istio.id}"

  tags = "${
    map(
     "Name", "terraform-eks-istio-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "istio" {
  vpc_id = "${aws_vpc.istio.id}"

  tags = {
    Name = "terraform-eks-istio"
  }
}

resource "aws_route_table" "istio" {
  vpc_id = "${aws_vpc.istio.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.istio.id}"
  }
}

resource "aws_route_table_association" "istio" {
  count = 2

  subnet_id      = "${aws_subnet.istio.*.id[count.index]}"
  route_table_id = "${aws_route_table.istio.id}"
}