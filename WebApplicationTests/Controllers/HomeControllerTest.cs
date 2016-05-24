using System;

using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Xunit;

using WebApplication.Controllers;

namespace WebApplicationTests.Controllers
{


    public class HomeControllerTest
    {
        [Fact]
        public void Index()
        {
            // Arrange
            HomeController controller = new HomeController();

            // Act
            ViewResult result = controller.Index() as ViewResult;

            // Assert
            Assert.NotNull(result);
            Debug.Assert(result != null, "result != null");
            Assert.Equal(0, result.ViewData.Count);
        }

        [Fact]
        public void About()
        {
            // Arrange
            HomeController controller = new HomeController();

            // Act
            ViewResult result = controller.About() as ViewResult;

            // Assert
            Assert.NotNull(result);
            Debug.Assert(result != null, "result != null");
            Assert.Equal(1, result.ViewData.Count);
            Assert.Equal("Your application description page.", result.ViewData["Message"]);
        }

        [Fact]
        public void Contact()
        {
            // Arrange
            HomeController controller = new HomeController();

            // Act
            ViewResult result = controller.Contact() as ViewResult;

            // Assert
            Assert.NotNull(result);
            Debug.Assert(result != null, "result != null");
            Assert.Equal(1, result.ViewData.Count);
            Assert.Equal("Your contact page.", result.ViewData["Message"]);
        }

        [Fact]
        public void Error()
        {
            // Arrange
            HomeController controller = new HomeController();

            // Act
            ViewResult result = controller.Error() as ViewResult;

            // Assert
            Assert.NotNull(result);
            Debug.Assert(result != null, "result != null");
            Assert.Equal(0, result.ViewData.Count);
        }
    }
}
