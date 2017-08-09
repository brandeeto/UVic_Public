package ca.uvic.seng426lab;

import static org.junit.Assert.*;

import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/*
 * A test covering all the ACMEPass functionality
 * as the role of a new user
 */

public class NewUser extends CommonFunctionality {
	
	/*
	 * Random email generator, creates an email for new user
	 */
	public String emailGen() {
		String email = "";
		
		for (int i = 0; i < 7; i++) {
			email += (char) ('a' + Math.random() * 26);
		}
		
		email += "@mail.com";
		
		return email;
	}
	
	private String email = emailGen();
	private String pass = "somepass";
	
	public void register() throws Exception {
		driver.findElement(By.cssSelector("a[ui-sref='register']")).click(); 
		driver.findElement(By.id("email")).sendKeys(email);
		driver.findElement(By.id("password")).sendKeys(pass);
		driver.findElement(By.id("confirmPassword")).sendKeys(pass);
		driver.findElement(By.cssSelector("button[type='submit']")).click();
		driver.findElement(By.cssSelector("a[ui-sref='home']")).click();
		// Sleep to give the system enough time to put the user in the system
		Thread.sleep(2000);
	}
	
	// Test the ability to view the ACME Pass entry list for a particular user
	@Test
	public void testViewACMEPassList() throws Exception {
		register();
		SignIn(email, pass);
		driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
	
		WebDriverWait wait = new WebDriverWait(driver, 20); //Wait time of 20 seconds
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ui-sref='acme-pass.new']")));
		
		String currentURL = driver.getCurrentUrl();
		assertEquals(currentURL, "http://localhost:8080/#/acme-pass");
	}
	
	// Test the basic creation of a ACME Pass entry
	@Test
	public void testCreateACMEPass() throws Exception {
		register();
		SignIn(email, pass);
		CreateNewACMEPass("testSite", "testUsername", "testPassword");
	}
	
	// Test editing of an ACME Pass entry
	@Test
	public void testEditAcmePass() throws Exception {
		// create acme pass in case one does not already exist
		register();
		SignIn(email, pass);
		CreateNewACMEPass("testSite", "testUsername", "testPassword");
		editACMEPass();		
	}
	
	// Test the deletion of an ACME Pass entry
	@Test
	public void testDeleteAcmePass() throws Exception {
		register();
		SignIn(email, pass);
		CreateNewACMEPass("testDeleteSite", "testDeleteUsername", "testDeletePassword");
		DeleteACMEPass();
	}
	
	// Test password generation
	@Test
	public void testGeneratePassword() throws Exception {
		register();
		SignIn(email, pass);
		GeneratePassword("testSite", "testUsername");
	}
	
	// Test creation of a random password
	@Test
	public void testCreateRandomPass() throws Exception {
		register();
		SignIn(email, pass);
		createRandomPass();
	}

	// Test creation of multiple random passwords
	@Test
	public void testCreateMultipleRandomPass() throws Exception {
		register();
		SignIn(email, pass);
		createMultipleRandomPass();
	}
	
	// Test the toggling of password visibility
	@Test
	public void testTogglePasswordVisability() throws Exception {
		fail("Not yet implemented");
	}
	
	// Test the sorting functionality of the ACME Pass entry list
	@Test
	public void testSorting() throws Exception {
		register();
		SignIn(email, pass);
		sort();
	}
	
	// Test the pagination of the ACME Pass entries table
	@Test
	public void testPagination() throws Exception {
		register();
		SignIn(email, pass);
		driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
		for(int i = 0; i <= 20; i++){
			CreateNewACMEPass("paginationTest_"+i, "paginationUsername_"+i, "paginationPassword_"+i);
		}
		
		// Traverse to next page		
		WebDriverWait wait = new WebDriverWait(driver, 5);
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("html/body/div[3]/div/div/ul/li[2]/a")));
		
		driver.findElement(By.xpath("html/body/div[3]/div/div/ul/li[2]/a")).click();
		String currentURL = driver.getCurrentUrl();
		Thread.sleep(500);
		assertEquals(currentURL, "http://localhost:8080/#/acme-pass?page=2");
		
		// Traverse to prev page
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("html/body/div[3]/div/div/ul/li[1]/a")));
		driver.findElement(By.xpath("html/body/div[3]/div/div/ul/li[1]/a")).click();
		
		currentURL = driver.getCurrentUrl();
		Thread.sleep(500);
		assertEquals(currentURL, "http://localhost:8080/#/acme-pass");
	}

}
