package ca.uvic.seng426lab;

import static org.junit.Assert.*;

import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/*
 * A test covering all the ACMEPass functionality
 * as the role of an Employee
 */
/*
frank.paul@acme.com	starwars	EMPLOYEE
paul.robert@acme.com	shadow	EMPLOYEE
tom.hayes@acme.com	superman	EMPLOYEE
alice.sandhu@acme.com	princess	EMPLOYEE*/

public class Employee extends CommonFunctionality {
	// Test the ability to view the ACME Pass entry list for a particular user
	@Test
	public void testViewACMEPassList() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		driver.findElement(By.cssSelector("a[ui-sref='acme-pass']")).click();
	
		WebDriverWait wait = new WebDriverWait(driver, 20); //Wait time of 20 seconds
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector("button[ui-sref='acme-pass.new']")));
		
		String currentURL = driver.getCurrentUrl();
		assertEquals(currentURL, "http://localhost:8080/#/acme-pass");
	}
	
	// Test the basic creation of a ACME Pass entry
	@Test
	public void testCreateACMEPass() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		CreateNewACMEPass("testSite", "testUsername", "testPassword");
	}
	
	// Test editing of an ACME Pass entry
	@Test
	public void testEditAcmePass() throws Exception {
		// create acme pass in case one does not already exist
		SignIn("paul.robert@acme.com", "shadow");
		CreateNewACMEPass("testSite", "testUsername", "testPassword");
		editACMEPass();		
	}
	
	@Test
	public void testPassowrdVisibility() throws Exception{
		SignIn("paul.robert@acme.com", "shadow");
		CreateNewACMEPass("testSite", "testUsername", "testPassword");
		passwordVisibility();
	}
	
	// Test the deletion of an ACME Pass entry
	@Test
	public void testDeleteAcmePass() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		CreateNewACMEPass("testDeleteSite", "testDeleteUsername", "testDeletePassword");
		DeleteACMEPass();
	}
	
	// Test password generation
	@Test
	public void testGeneratePassword() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		GeneratePassword("testSite", "testUsername");
	}
	
	// Test creation of a random password
	@Test
	public void testCreateRandomPass() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		createRandomPass();
	}
	
	// Test creation of multiple random passwords
	@Test
	public void testCreateMultipleRandomPass() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
		createMultipleRandomPass();
	}
	
	// Test the toggling of password visibility
	@Test
	public void testTogglePasswordVisability() throws Exception {
		fail("Not yet implemented");
	}
	
	// Test the pagination of the ACME Pass entries table
	@Test
	public void testPagination() throws Exception {
		SignIn("paul.robert@acme.com", "shadow");
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
																																	
