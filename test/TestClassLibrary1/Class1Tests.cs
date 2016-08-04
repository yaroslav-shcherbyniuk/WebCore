using ClassLibrary1;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;

namespace TestClassLibrary1
{
    public class Class1Tests
    {
        public Class1Tests()
        {
        }


        [Fact]
        public void Add()
        {
            Assert.Equal(4, Class1.Add(2, 2));
        }
    }
}
