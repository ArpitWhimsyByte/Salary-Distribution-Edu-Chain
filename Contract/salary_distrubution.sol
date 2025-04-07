// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SalaryDistribution {
    address public owner;

    struct Employee {
        uint salary;
        bool exists;
    }

    mapping(address => Employee) public employees;
    address[] public employeeList;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEmployee(address _employee, uint _salary) external onlyOwner {
        require(!employees[_employee].exists, "Employee already exists");
        employees[_employee] = Employee(_salary, true);
        employeeList.push(_employee);
    }

    function updateSalary(address _employee, uint _newSalary) external onlyOwner {
        require(employees[_employee].exists, "Employee not found");
        employees[_employee].salary = _newSalary;
    }

    function removeEmployee(address _employee) external onlyOwner {
        require(employees[_employee].exists, "Employee not found");
        delete employees[_employee];

        // Remove from employeeList
        for (uint i = 0; i < employeeList.length; i++) {
            if (employeeList[i] == _employee) {
                employeeList[i] = employeeList[employeeList.length - 1];
                employeeList.pop();
                break;
            }
        }
    }

    function distributeSalaries() external payable onlyOwner {
        uint totalRequired = 0;

        for (uint i = 0; i < employeeList.length; i++) {
            if (employees[employeeList[i]].exists) {
                totalRequired += employees[employeeList[i]].salary;
            }
        }

        require(msg.value >= totalRequired, "Insufficient funds to pay salaries");

        for (uint i = 0; i < employeeList.length; i++) {
            address payable emp = payable(employeeList[i]);
            if (employees[emp].exists) {
                emp.transfer(employees[emp].salary);
            }
        }
    }

    function getAllEmployees() public view returns (address[] memory) {
        return employeeList;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Allow owner to deposit Ether
    receive() external payable {}
}

 
