package ca.uvic.seng426lab;
import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.junit.Before;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/*
 * Contains functionality common between Basic Users, Employee, 
 * Manager, and Admin tests as helper methods
 *  
 */

public class CommonFunctionality extends TestSetup{
	
	
//	protected WebDriver driver;
//	//public WebDriverWait wait = new WebDriverWait(driver, 10);
//	private String baseUrl = "http://localhost:8080";
//
//
//	@Before
//	public void setUp() throws Exception {
//			System.setProperty("webdriver.gecko.driver", "/home/mwardle/Desktop/SENG426/geckodriver");
//			driver = new FirefoxDriver();
//			driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
//			driver.get(baseUrl);
//			driver.manage().window().maximize();
//			
//			// not sure if we'll need these in the future - keeping them until decided
////			driver.manage().timeouts().pageLoadTimeout(10, TimeUnit.SECONDS);
////			driver.manage().timeouts().setScriptTimeout(5, TimeUnit.SECONDS)
//	}	
//	
//	/* Method for signing a user in with the provided credentials
//	 * 
//	 * Parameters:
//	 * String username: The users username
//	 * String password: The users password
//	 * Return: void
//	*/
//	
//	protected void SignIn(String username, String password) throws Exception {
//		driver.manage().timeouts().setScriptTimeout(5,TimeUnit.SECONDS);
//				
//		try{
//			driver.findElement(By.id("login")).click();
//			driver.findElement(By.id("username")).sendKeys(username);
//			driver.findElement(By.id("password")).sendKeys(password);
//			driver.findElement(By.cssSelector("button[type='submit']")).click();
//		}catch(Exception e){
//			System.out.println("Error occurred in SignIn");
//			throw(e);
//		}
//	}
	
	protected void CreateNewACMEPass(String sitename, String username, String password) throws Exception {
		try{
			// Navigate to ACME Pass management page
			Thread.sleep(500);
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			
			// Open form to create new ACME Pass
			Thread.sleep(500);
			driver.findElement(By.cssSelector("button[ui-sref='acme-pass.new']")).click();			
			
			// Fill in form
			driver.findElement(By.id("field_site")).sendKeys(sitename);
			driver.findElement(By.id("field_login")).sendKeys(username);
			driver.findElement(By.id("field_password")).sendKeys(password);
			driver.findElement(By.cssSelector("button[type='submit']")).click();
		}catch(Exception e){
			System.out.println("Error occurred in CreateNewACMEPass");
			throw(e);
		}
	}
	
	protected void DeleteACMEPass() throws Exception {
		try{
			WebDriverWait wait = new WebDriverWait(driver, 20); //Wait time of 20 seconds
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("jh-table")));		
			WebElement baseTable = driver.findElement(By.className("jh-table"));
			List<WebElement> tableRows = baseTable.findElements(By.tagName("tr"));
			System.out.println("NUMBER OF ROWS="+tableRows.size());
		        int row_num, col_num;
		        String delete_url = "";
		        List<String> id_list =  new ArrayList<String>();
		        row_num=1;
		        // Loop through here to get the appropriate table ID
		        for(WebElement trElement : tableRows) {
		            List<WebElement> td_collection=trElement.findElements(By.xpath("td"));
			            col_num=1;
			            for(WebElement tdElement : td_collection) {
			            	// System.out.println("row # "+row_num+", col # "+col_num+ "text="+tdElement.getText());
			                if (col_num == 1 && tdElement.getText() != null){
						// append to a list that contains all visible elements to delete
			                	delete_url = "button[href='#/acme-pass/" + tdElement.getText() + "/delete']";
			                	id_list.add(delete_url);
			                }
		                col_num++;
			            }
	        	    row_num++;
		        } 
		        // Loop through here to delete ACMEPass, can't put them in forloop on top, async
		        String css_temp = "";
		        for(int i = 0; i < id_list.size(); i++) {
	        		css_temp = id_list.get(i);
				// Delete the ACMEPass, by clicking on the delete delete button, followed by the submit button
		        	System.out.println("Attempting to Delete: " +id_list.get(i));
		        	driver.findElement(By.cssSelector(css_temp)).click();
		        	wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[type='submit']")));
		    		driver.findElement(By.cssSelector("button[type='submit']")).click();
				// Check if the element exists, on the webpage, if it does, it has not been deleted.
		    		if (driver.findElement(By.cssSelector(css_temp))!=null) {
	    				System.out.println("Failed to Delete: " +css_temp);
		    		} else {
		    			System.out.println("Delete Success");
		    		}
		        }
		}catch(Exception e){
			System.out.println("Error occurred in DeleteACMEPass");
			throw(e);
		}
	}
	
	protected void editACMEPass() throws Exception {
		try{			
			// get the initial values of the strings to be edited 
			String initSiteString = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[2]")).getText();
			String initLoginString = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[3]")).getText();
			
			// click on the edit button of the first row
			driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[7]/div/button[1]")).click();
			
			// edit site
			driver.findElement(By.id("field_site")).sendKeys("_Edited");
					
			// edit login
			driver.findElement(By.id("field_login")).sendKeys("_Edited");
					
			// edit password
			driver.findElement(By.id("field_password")).sendKeys("_Edited");
					
			// click save
			driver.findElement(By.xpath("html/body/div[1]/div/div/form/div[3]/button[2]")).click();
			
			// check site was edited
			String editedSiteString = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[2]")).getText();
			if(!editedSiteString.equals(initSiteString + "_Edited")){
				System.out.println("ERROR: ACMEPass site could not be edited. Inital Site: " + initSiteString + " Edited Site: " + editedSiteString);
				//driver.close();
			}
			
			// check login was edited
			String editedLoginString = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[3]")).getText();
			if(!editedLoginString.equals(initLoginString + "_Edited")){
				System.out.println("ERROR: ACMEPass login could not be edited. Inital Login: " + initLoginString + " Edited Login: " + editedLoginString);
				//driver.close();
			}
			
		}catch (Exception e){
			System.out.println("Error occurred in EditACMEPass");
			throw(e);
		}
	}
	
	protected void passwordVisibility() throws Exception {
		try{			
			
			// get password element
			WebElement password = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[4]/div/input"));
						
			//toggle visibility
			driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[4]/div/span")).click();
			
			// check toggle
			if(!password.getAttribute("type").equals("text")){
				System.out.println("ERROR: password visibility did not toggle correctly");
			}
			
			// go to edit view
			driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[7]/div/button[1]")).click();
								
			// get password element
			password = driver.findElement(By.id("field_password"));
			
			//toggle visibility
			driver.findElement(By.xpath("html/body/div[1]/div/div/form/div[2]/div[4]/div[1]/div[1]/span")).click();
			
			// check toggle
			if(!password.getAttribute("type").equals("text")){
				System.out.println("ERROR: password visibility did not toggle correctly");
			}
			
		}catch (Exception e){
			System.out.println("Error occurred in editPasswordVisibility");
			throw(e);
		}
	}

	protected void sort() throws Exception {
		try{
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			CreateNewACMEPass("111", "114", "test");
			CreateNewACMEPass("112", "113", "test");
			
			// Test sorting on siteName
			driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/thead/tr/th[2]/span[2]")).click();
			String siteName = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[2]")).getText();
			String login = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[3]")).getText();
			assertEquals(siteName, "111");
			assertEquals(login, "114");
			
			siteName = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[2]/td[2]")).getText();
			login = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[2]/td[3]")).getText();
			assertEquals(siteName, "112");
			assertEquals(login, "113");
			
			// Test sorting on login
			driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/thead/tr/th[3]/span[2]")).click();
			siteName = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[2]")).getText();
			login = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[1]/td[3]")).getText();
			assertEquals(siteName, "112");
			assertEquals(login, "113");
					
			siteName = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[2]/td[2]")).getText();
			login = driver.findElement(By.xpath("html/body/div[3]/div/div/div[2]/table/tbody/tr[2]/td[3]")).getText();
			assertEquals(siteName, "111");
			assertEquals(login, "114");
		}catch (Exception e){
			System.out.println("Error occured in sort");
			throw(e);
		}
	}
	
	protected void createRandomPass() throws Exception {
		try{
			WebDriverWait wait = new WebDriverWait(driver, 20); //Wait time of 20 seconds
			driver.manage().timeouts().setScriptTimeout(5,TimeUnit.SECONDS);
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			driver.manage().timeouts().setScriptTimeout(1,TimeUnit.SECONDS);
		
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
				
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ui-sref='acme-pass.new']")));		
			
			driver.findElement(By.cssSelector("button[ui-sref='acme-pass.new']")).click();
			driver.manage().timeouts().setScriptTimeout(2,TimeUnit.SECONDS);
			driver.findElement(By.cssSelector("button[ui-sref='acme-pass.new']")).click();
			driver.manage().timeouts().setScriptTimeout(3,TimeUnit.SECONDS);
			
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("field_site")));		
			driver.findElement(By.id("field_site")).sendKeys("TestSite");
			driver.findElement(By.id("field_login")).sendKeys("John");
		
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ng-click='vm.openPwdGenModal()']")));			
			driver.findElement(By.cssSelector("button[ng-click='vm.openPwdGenModal()']")).click();
			
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ng-click='vm.generate()']")));			
			driver.findElement(By.cssSelector("button[ng-click='vm.generate()']")).click();
			driver.findElement(By.cssSelector("button[type='submit']")).click();
		
			wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[type='submit']")));			
			driver.findElement(By.cssSelector("button[type='submit']")).click();
		}catch (Exception e){
			System.out.println("Error occurred in createRandomPass");
			throw(e);
		}
	}
	
	protected void createMultipleRandomPass() throws Exception {
		try{
			WebDriverWait wait = new WebDriverWait(driver, 20); //Wait time of 20 seconds
			driver.manage().timeouts().setScriptTimeout(5,TimeUnit.SECONDS);
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			driver.manage().timeouts().setScriptTimeout(1,TimeUnit.SECONDS);
		
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
				
			for(int i = 0; i< 20; i++){
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ui-sref='acme-pass.new']")));		
				
				driver.findElement(By.cssSelector("button[ui-sref='acme-pass.new']")).click();
				driver.manage().timeouts().setScriptTimeout(2,TimeUnit.SECONDS);
				driver.findElement(By.cssSelector("button[ui-sref='acme-pass.new']")).click();
				driver.manage().timeouts().setScriptTimeout(3,TimeUnit.SECONDS);
				
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("field_site")));		
				driver.findElement(By.id("field_site")).sendKeys("TestSite");
				driver.findElement(By.id("field_login")).sendKeys("John");
			
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ng-click='vm.openPwdGenModal()']")));			
				driver.findElement(By.cssSelector("button[ng-click='vm.openPwdGenModal()']")).click();
				
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ng-click='vm.generate()']")));			
				driver.findElement(By.cssSelector("button[ng-click='vm.generate()']")).click();
				driver.findElement(By.cssSelector("button[type='submit']")).click();
		
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[type='submit']")));			
				driver.findElement(By.cssSelector("button[type='submit']")).click();
			}
		}catch (Exception e){
			System.out.println("Error occurred in createMultipleRandomPass");
			throw(e);
		}
	}
	
	protected void GeneratePass_DeselectAll(){
		if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.lower']")).getAttribute("class").contains("ng-not-empty")){
			driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.lower']")).click();
		}
		
		if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.upper']")).getAttribute("class").contains("ng-not-empty")){
			driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.upper']")).click();
		}
		
		if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.digits']")).getAttribute("class").contains("ng-not-empty")){
			driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.digits']")).click();
		}
		
		if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.special']")).getAttribute("class").contains("ng-not-empty")){
			driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.special']")).click();
		}
		
		if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.repetition']")).getAttribute("class").contains("ng-not-empty")){
			driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.repetition']")).click();
		}
		
		driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.length']")).clear();
	}
	
	
	protected void GeneratePass_TestLower(String password) throws Exception {
		try{
			for(int i = 0; i<password.length(); i++){
				if (Character.isLowerCase(password.charAt(i))) return;
			}
			
			fail("Failed lower case test when generating password: " + password);
			
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestLower. \nPassword (" + password + ")\n^^^ Doesn't have a LowerCase char. ^^^\n");
		}
	}
	
	protected void GeneratePass_TestUpper(String password) throws Exception {
		try{
			for(int i = 0; i<password.length(); i++){
				if (Character.isUpperCase(password.charAt(i))) return;
			}
			
			fail("Failed uppper case test when generating password: " + password);
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestUpper. \n Password (" + password + ")\n^^^ Doesn't have an UpperCase char. ^^^\n");
		}
	}
	
	protected void GeneratePass_TestDigits(String password) throws Exception {
		try{
			for(int i = 0; i<password.length(); i++){
				if (Character.isDigit(password.charAt(i))) return;
			}
			
			fail("Failed digits test when generating password: " + password);
			
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestDigits. \nPassword (" + password + ")\n^^^ Doesn't have a digit. ^^^\n");
		}
	}
	
	protected void GeneratePass_TestSpecial(String password) throws Exception {
		try{
			String specialString = "!@#$%-_";
			
			for(int i = 0; i<password.length(); i++){
				if (specialString.indexOf(password.charAt(i)) != -1) return;
			}
			
			fail("Failed special char test when generating password: " + password);
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestSpecial. \nPassword (" + password + ")\n^^^ Doesn't have a special character. ^^^\n");
		}
	}
	
	protected void GeneratePass_TestRepetition(String password) throws Exception {
		try{
			for(int i = 0; i<password.length(); i++){
				if (i == 0) {
					
				} else if (password.charAt(i) == password.charAt(i-1)) {
					fail("Failed repetition test when generating password: " + password);
				}
			}
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestRepetition. \nPassword (" + password + ") \n^^^ Contains repetition. ^^^\n");
		}
	}
	
	protected void GeneratePass_TestLength(String password, String length) throws Exception {
		try{
			if (password.length() == Integer.parseInt(length)) {
				return;
			} else {
				fail("Failed length test when generating password: " + password);
			}
			
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword_TestLength. \nPassword (" + password + ")\n^^^ Doesn't meet length requirement. ^^^\n");
		}
	}
	
	protected void GeneratePass_Test(Boolean lower, Boolean upper, Boolean digits, Boolean special, Boolean repetition, String length) throws Exception{
		
		GeneratePass_DeselectAll();
		
		if (lower) {
			if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.lower']")).getAttribute("class").contains("ng-empty")){
				driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.lower']")).click();
			}
		}
		
		if (upper) {
			if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.upper']")).getAttribute("class").contains("ng-empty")){
				driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.upper']")).click();
			}
		}
		
		if (digits) {
			if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.digits']")).getAttribute("class").contains("ng-empty")){
				driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.digits']")).click();
			}
		}
		
		if (special) {
			if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.special']")).getAttribute("class").contains("ng-empty")){
				driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.special']")).click();
			}
		}
		
		if (repetition) {
			if (driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.repetition']")).getAttribute("class").contains("ng-empty")){
				driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.repetition']")).click();
			}
		}
		
		driver.findElement(By.cssSelector("input[ng-model='vm.genOptions.length']")).sendKeys(length);
		
		Thread.sleep(100);
		
		driver.findElement(By.cssSelector("button[ng-click='vm.generate()']")).click();
		
		Thread.sleep(10000);
		
		String password = driver.findElement(By.id("field_password")).getAttribute("value");
		
		if (lower) {
			GeneratePass_TestLower(password);
		}
		
		if (upper) {
			GeneratePass_TestUpper(password);
		}
		
		if (digits) {
			GeneratePass_TestDigits(password);
		}
		
		if (special) {
			GeneratePass_TestSpecial(password);
		}
		
		if (repetition) {
			GeneratePass_TestRepetition(password);
		}
		
		GeneratePass_TestLength(password, length);
		
	}
	
	protected void GeneratePassword(String sitename, String username) throws Exception {
		try{
			// Navigate to ACME Pass management page
			driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
			
			// Open form to create new ACME Pass
			driver.findElement(By.cssSelector("span[class='glyphicon glyphicon-plus']")).click();
	
			// Fill in partial form and click the generate password 
			driver.findElement(By.id("field_site")).sendKeys("Test_Site");
			driver.findElement(By.id("field_login")).sendKeys("Test_Login");
			driver.findElement(By.cssSelector("button[ng-click='vm.openPwdGenModal()']")).click();
			
			String password_length = "500";
			
			// All true
			GeneratePass_Test(true, true, true, true, true, password_length);
			
			// One false
			GeneratePass_Test(false, true, true, true, true, password_length);
			GeneratePass_Test(true, false, true, true, true, password_length);
			GeneratePass_Test(true, true, false, true, true, password_length);
			GeneratePass_Test(true, true, true, false, true, password_length);
			GeneratePass_Test(true, true, true, true, false, password_length);
			
			// Two false
			GeneratePass_Test(false, false, true, true, true, password_length);
			GeneratePass_Test(false, true, false, true, true, password_length);
			GeneratePass_Test(false, true, true, false, true, password_length);
			GeneratePass_Test(false, true, true, true, false, password_length);
			
			GeneratePass_Test(true, false, false, true, true, password_length);
			GeneratePass_Test(true, false, true, false, true, password_length);
			GeneratePass_Test(true, false, true, true, false, password_length);
			
			GeneratePass_Test(true, true, false, false, true, password_length);
			GeneratePass_Test(true, true, false, true, false, password_length);
			
			GeneratePass_Test(true, true, true, false, false, password_length);
			
			// Three false
			GeneratePass_Test(false, false, false, true, true, password_length);
			GeneratePass_Test(false, false, true, false, true, password_length);
			GeneratePass_Test(false, false, true, true, false, password_length);
			
			GeneratePass_Test(false, true, false, false, true, password_length);
			GeneratePass_Test(false, true, false, true, false, password_length);
			
			GeneratePass_Test(true, false, false, false, true, password_length);
			GeneratePass_Test(true, false, false, true, false, password_length);
			
			GeneratePass_Test(true, true, false, false, false, password_length);
			
			// Four false
			GeneratePass_Test(false, false, false, false, true, password_length);
			GeneratePass_Test(false, false, false, true, false, password_length);
			GeneratePass_Test(false, false, true, false, false, password_length);
			GeneratePass_Test(false, true, false, false, false, password_length);
			GeneratePass_Test(true, false, false, false, false, password_length);
			
			// All false, no need for this
			
		} catch(Exception e){
			System.out.println("Error occurred in GeneratePassword");
		}

	}
}
